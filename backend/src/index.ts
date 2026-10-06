import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { sign, verify } from 'hono/jwt'

type Bindings = {
  DB: D1Database
  UPLOADS: R2Bucket
  JWT_SECRET: string
  PAYMENT_SECRET: string
  PADDLE_API_KEY: string
  PADDLE_WEBHOOK_SECRET: string
  PAYSTACK_SECRET_KEY: string
  PAYSTACK_PUBLIC_KEY: string
  PAYSTACK_STANDARD_PLAN: string
  PAYSTACK_STUDENT_PLAN: string
}

const app = new Hono<{ Bindings: Bindings }>()

app.use('/api/*', cors())

app.get('/api/health', (c) => c.json({ ok: true }))

// --- Authentication ---
app.post('/api/auth/register', async (c) => {
  const { email, passwordHash, salt, wrappedKeyPwd, wrappedKeyRecovery } = await c.req.json()
  const id = crypto.randomUUID()
  
  try {
    await c.env.DB.prepare(
      'INSERT INTO accounts (id, email, password_hash, salt, wrapped_key_pwd, wrapped_key_recovery, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)'
    ).bind(id, email, passwordHash, salt, wrappedKeyPwd || null, wrappedKeyRecovery || null, Date.now()).run()
    
    const token = await sign({ id, exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 30 }, c.env.JWT_SECRET)
    return c.json({ token, id, salt })
  } catch (e: any) {
    if (e.message.includes('UNIQUE constraint failed')) {
      return c.json({ error: 'Email already exists' }, 400)
    }
    return c.json({ error: 'Internal error' }, 500)
  }
})

app.post('/api/auth/login', async (c) => {
  const { email, passwordHash } = await c.req.json()
  
  const account = await c.env.DB.prepare('SELECT id, password_hash, salt, wrapped_key_pwd, wrapped_key_recovery FROM accounts WHERE email = ?')
    .bind(email).first<{id: string, password_hash: string, salt: string, wrapped_key_pwd: string | null, wrapped_key_recovery: string | null}>()
    
  if (!account || account.password_hash !== passwordHash) {
    return c.json({ error: 'Invalid credentials' }, 401)
  }
  
  const token = await sign({ id: account.id, exp: Math.floor(Date.now() / 1000) + 60 * 60 * 24 * 30 }, c.env.JWT_SECRET)
  return c.json({ token, id: account.id, salt: account.salt, wrappedKeyPwd: account.wrapped_key_pwd })
})

// Auth middleware for sync routes
app.use('/api/sync/*', async (c, next) => {
  const auth = c.req.header('Authorization')
  if (!auth || !auth.startsWith('Bearer ')) return c.json({ error: 'Unauthorized' }, 401)
  
  try {
    const payload = await verify(auth.slice(7), c.env.JWT_SECRET)
    c.set('accountId', payload.id)
    
    // Check subscription status
    const account = await c.env.DB.prepare('SELECT subscription_status FROM accounts WHERE id = ?')
      .bind(payload.id).first<{subscription_status: string}>()
      
    if (!account || account.subscription_status === 'free') {
      return c.json({ error: 'Subscription required for sync' }, 403)
    }
    
    await next()
  } catch (e) {
    return c.json({ error: 'Invalid token' }, 401)
  }
})

// --- Sync Engine (Last-Write-Wins) ---
app.get('/api/sync/:collection', async (c) => {
  const accountId = c.get('accountId')
  const collection = c.req.param('collection')
  const since = parseInt(c.req.query('since') || '0', 10)
  
  const { results } = await c.env.DB.prepare(
    'SELECT record_id, encrypted_data, updated_at FROM sync_blobs WHERE account_id = ? AND collection = ? AND updated_at > ?'
  ).bind(accountId, collection, since).all()
  
  return c.json({ items: results })
})

app.post('/api/sync/:collection', async (c) => {
  const accountId = c.get('accountId')
  const collection = c.req.param('collection')
  const { items } = await c.req.json() // Array of { record_id, encrypted_data, updated_at }
  
  // Basic LWW reconciliation (bulk upsert with condition)
  const statements = items.map((item: any) => {
    return c.env.DB.prepare(`
      INSERT INTO sync_blobs (account_id, collection, record_id, encrypted_data, updated_at) 
      VALUES (?, ?, ?, ?, ?)
      ON CONFLICT(account_id, collection, record_id) DO UPDATE SET 
      encrypted_data = excluded.encrypted_data, updated_at = excluded.updated_at
      WHERE excluded.updated_at > sync_blobs.updated_at
    `).bind(accountId, collection, item.record_id, item.encrypted_data, item.updated_at)
  })
  
  if (statements.length > 0) {
    await c.env.DB.batch(statements)
  }
  
  return c.json({ success: true })
})

// --- Pricing / Checkout (Purchasing Power Parity) ---
app.get('/api/checkout/price', async (c) => {
  const country = c.req.raw.cf?.country as string || 'US'
  const isStudent = c.req.query('student') === 'true'
  
  let priceUSD = isStudent ? 1.50 : 3.00
  let currency = 'USD'
  
  if (country === 'NG') {
    priceUSD = isStudent ? 0.50 : 0.85 // ~800 / 1400 NGN equivalent
    currency = 'NGN'
  } else if (!['US', 'GB', 'CA', 'AU', 'EU'].includes(country)) {
    priceUSD = priceUSD * 0.5
  }
  
  return c.json({ country, priceUSD, currency })
})

// --- Student Verification ---
app.post('/api/student/verify', async (c) => {
  const auth = c.req.header('Authorization')
  if (!auth) return c.json({ error: 'Unauthorized' }, 401)
  
  try {
    const payload = await verify(auth.slice(7), c.env.JWT_SECRET)
    const accountId = payload.id
    
    // Check if body is FormData
    const body = await c.req.parseBody()
    const file = body['document'] as File
    
    if (!file) return c.json({ error: 'Missing document' }, 400)
    
    const docKey = `verifications/${accountId}-${Date.now()}-${file.name}`
    
    // Store in R2
    await c.env.UPLOADS.put(docKey, await file.arrayBuffer(), {
      httpMetadata: { contentType: file.type }
    })
    
    // Record in D1
    const verifId = crypto.randomUUID()
    await c.env.DB.prepare(
      'INSERT INTO student_verifications (id, account_id, document_key, created_at) VALUES (?, ?, ?, ?)'
    ).bind(verifId, accountId, docKey, Date.now()).run()
    
    return c.json({ success: true, verificationId: verifId })
  } catch (e) {
    return c.json({ error: 'Failed to submit verification' }, 500)
  }
})

// --- Student Verification Admin (Mocked) ---
app.post('/api/admin/verify/approve', async (c) => {
  const auth = c.req.header('Authorization')
  if (auth !== 'Bearer admin_secret') return c.json({ error: 'Unauthorized' }, 401)
  
  const { verificationId, approved } = await c.req.json()
  
  const verif = await c.env.DB.prepare('SELECT account_id, document_key FROM student_verifications WHERE id = ?')
    .bind(verificationId).first<{account_id: string, document_key: string}>()
    
  if (!verif) return c.json({ error: 'Not found' }, 404)
  
  // 1. Data Minimization: Delete the supporting document immediately from R2
  await c.env.UPLOADS.delete(verif.document_key)
  
  // 2. Update statuses
  const newStatus = approved ? 'approved' : 'rejected'
  await c.env.DB.prepare('UPDATE student_verifications SET status = ?, document_key = NULL WHERE id = ?')
    .bind(newStatus, verificationId).run()
    
  if (approved) {
    await c.env.DB.prepare("UPDATE accounts SET subscription_status = 'student' WHERE id = ?")
      .bind(verif.account_id).run()
  }
  
  return c.json({ success: true, accountId: verif.account_id, approved })
})

// --- Paddle Webhooks & Fulfillment ---
app.post('/api/webhooks/paddle', async (c) => {
  // IP Allowlisting Security Check for Live Webhooks
  try {
    const ipRes = await fetch('https://api.paddle.com/ips');
    const ipData = await ipRes.json() as any;
    const allowedIps = ipData.details?.ipv4_cidrs || [];
    
    const connectingIp = c.req.header('cf-connecting-ip');
    const connectingIpSlash32 = connectingIp ? `${connectingIp}/32` : '';
    
    // If the connecting IP doesn't match Paddle's dynamic live CIDRs, block it
    if (connectingIp && !allowedIps.includes(connectingIpSlash32)) {
      return c.json({ error: 'Unauthorized IP' }, 403);
    }
  } catch (e) {
    return c.json({ error: 'Security check failed' }, 500);
  }

  const paddleApiKey = c.env.PADDLE_API_KEY?.trim() || 'pdl_live_apikey_01m3jhwkqzk7k92rs1pvrt2ka1_70gqfnWjKJEa3Cb9RqzSNF_ANj';
  const paddleWebhookSecret = c.env.PADDLE_WEBHOOK_SECRET?.trim() || 'pdl_ntfset_01m3jk2w0qxjn12xjhjha6215e_MesyQQiR2r80t3G+MK3P1soFYROiXppG';
  
  const paddle = new (await import('@paddle/paddle-node-sdk')).Paddle(paddleApiKey, { 
    environment: (await import('@paddle/paddle-node-sdk')).Environment.production 
  })
  const signature = c.req.header('paddle-signature')
  
  if (!signature) return c.json({ error: 'Missing signature' }, 401)
  
  const rawBody = await c.req.text()
  
  try {
    const event = paddle.webhooks.unmarshal(rawBody, paddleWebhookSecret, signature)
    
    const eType = event.eventType || (event as any).type || '';
    
    // Idempotent upserts for entities
    if (eType.startsWith('customer.')) {
      const data = event.data as any
      await c.env.DB.prepare(`
        INSERT INTO customers (customer_id, email, created_at, updated_at)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(customer_id) DO UPDATE SET
        email = excluded.email, updated_at = excluded.updated_at
      `).bind(data.id, data.email, data.createdAt, data.updatedAt).run()
    } else if (eType.startsWith('subscription.')) {
      const data = event.data as any
      const priceId = data.items?.[0]?.price?.id || ''
      const productId = data.items?.[0]?.price?.productId || ''
      
      await c.env.DB.prepare(`
        INSERT INTO subscriptions (subscription_id, customer_id, status, price_id, product_id, scheduled_change_action, scheduled_change_at, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(subscription_id) DO UPDATE SET
        status = excluded.status, price_id = excluded.price_id, product_id = excluded.product_id,
        scheduled_change_action = excluded.scheduled_change_action, scheduled_change_at = excluded.scheduled_change_at,
        updated_at = excluded.updated_at
      `).bind(
        data.id, data.customerId, data.status, priceId, productId,
        data.scheduledChange?.action || null, data.scheduledChange?.effectiveAt || null,
        data.createdAt, data.updatedAt
      ).run()
      
      // Update account status based on customData.account_id
      if (data.customData?.account_id) {
        // Access helper logic: active AND trialing grant access.
        const isActive = ['active', 'trialing'].includes(data.status);
        const subStatus = isActive ? 'active' : 'free'
        await c.env.DB.prepare('UPDATE accounts SET subscription_status = ?, subscription_id = ? WHERE id = ?')
          .bind(subStatus, data.id, data.customData.account_id).run()
      }
    }
    
    return c.text('OK')
  } catch (err: any) {
    console.error("Webhook error:", err.message)
    return c.json({ error: err.message, stack: err.stack }, 400)
  }
})

// --- Paystack Webhooks & Checkout ---
app.post('/api/paystack/checkout', async (c) => {
  const { plan, email = 'user@daybefore.app' } = await c.req.json()
  
  const standardPlan = c.env.PAYSTACK_STANDARD_PLAN?.trim() || 'PLN_imvt06adlo6rdk0'
  const studentPlan = c.env.PAYSTACK_STUDENT_PLAN?.trim() || 'PLN_0iuejc9p3wkfsk9'
  const secretKey = c.env.PAYSTACK_SECRET_KEY?.trim() || 'sk_live_39277e4ba54bcc3a9f1f08ecb79b333a997ac95a'

  const planCode = plan === 'student' ? studentPlan : standardPlan
  
  if (!planCode) {
    return c.json({ error: 'Paystack plan code not configured' }, 500)
  }

  const response = await fetch('https://api.paystack.co/transaction/initialize', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${secretKey}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      email,
      plan: planCode,
      channels: ['card', 'bank'] // Enable card and direct debit
    })
  })

  const data = await response.json() as any
  if (data.status && data.data?.authorization_url) {
    return c.json({ url: data.data.authorization_url })
  }
  
  return c.json({ error: 'Failed to initialize Paystack', details: data })
})

app.post('/api/webhooks/paystack', async (c) => {
  const signature = c.req.header('x-paystack-signature')
  if (!signature) return c.json({ error: 'Missing signature' }, 401)
  
  const rawBody = await c.req.text()
  
  // Verify HMAC SHA512 signature
  const secretKey = c.env.PAYSTACK_SECRET_KEY?.trim() || 'sk_live_39277e4ba54bcc3a9f1f08ecb79b333a997ac95a'
  const crypto = await import('node:crypto')
  const expectedHash = crypto.createHmac('sha512', secretKey).update(rawBody).digest('hex')
  if (signature !== expectedHash) {
    return c.json({ error: 'Invalid signature' }, 400)
  }
  
  const event = JSON.parse(rawBody)
  
  try {
    // Treat Paystack success events as activating the account
    if (event.event === 'charge.success' || event.event === 'subscription.create') {
      const email = event.data?.customer?.email
      if (email) {
        // Activate account (processor-agnostic)
        await c.env.DB.prepare("UPDATE accounts SET subscription_status = 'active' WHERE email = ?")
          .bind(email).run()
      }
    } else if (event.event === 'subscription.disable') {
      const email = event.data?.customer?.email
      if (email) {
        await c.env.DB.prepare("UPDATE accounts SET subscription_status = 'free' WHERE email = ?")
          .bind(email).run()
      }
    }
    
    return c.text('OK')
  } catch (err: any) {
    console.error("Paystack webhook error:", err.message)
    return c.json({ error: 'Webhook processing failed' }, 500)
  }
})


  // --- Student Verification ---
  app.post('/api/student/upload', async (c) => {
    const user = c.get('jwtPayload')
    const body = await c.req.parseBody()
    const file = body['file'] as any
    if (!file) return c.json({ error: 'No file' }, 400)
    
    const id = crypto.randomUUID()
    const key = `students/${user.id}/${id}`
    await c.env.UPLOADS.put(key, file.stream())
    
    await c.env.DB.prepare('INSERT INTO student_verifications (id, account_id, document_key, created_at) VALUES (?, ?, ?, ?)').bind(id, user.id, key, Date.now()).run()
    return c.json({ success: true, id })
  })
  
  app.get('/api/admin/verifications', async (c) => {
    if (c.req.header('Authorization') !== 'Bearer ' + c.env.JWT_SECRET) return c.json({error: 'unauthorized'}, 401)
    const { results } = await c.env.DB.prepare('SELECT * FROM student_verifications WHERE status = \'pending\'').all()
    return c.json({ results })
  })
  
  app.post('/api/admin/verify', async (c) => {
    if (c.req.header('Authorization') !== 'Bearer ' + c.env.JWT_SECRET) return c.json({error: 'unauthorized'}, 401)
    const { id, approved } = await c.req.json()
    const verif = await c.env.DB.prepare('SELECT account_id FROM student_verifications WHERE id = ?').bind(id).first<{account_id: string}>()
    if (!verif) return c.json({error: 'Not found'}, 404)
    
    await c.env.DB.prepare('UPDATE student_verifications SET status = ? WHERE id = ?').bind(approved ? 'approved' : 'rejected', id).run()
    
    if (approved) {
      await c.env.DB.prepare('UPDATE accounts SET student_until = ? WHERE id = ?').bind(Date.now() + 365 * 24 * 60 * 60 * 1000, verif.account_id).run()
    }
    return c.json({ success: true })
  })
  // --- Customer Portal Session ---
app.post('/api/portal', async (c) => {
  const auth = c.req.header('Authorization')
  if (!auth) return c.json({ error: 'Unauthorized' }, 401)
  
  try {
    const payload = await verify(auth.slice(7), c.env.JWT_SECRET)
    const accountId = payload.id
    
    // Check if the user has a subscription ID stored
    const account = await c.env.DB.prepare('SELECT subscription_id FROM accounts WHERE id = ?')
      .bind(accountId).first<{subscription_id: string}>()
      
    if (!account || !account.subscription_id) {
      return c.json({ error: 'No subscription found for this account' }, 404)
    }
    
    // Get the customer ID from our mirrored DB table
    const sub = await c.env.DB.prepare('SELECT customer_id FROM subscriptions WHERE subscription_id = ?')
      .bind(account.subscription_id).first<{customer_id: string}>()
      
    if (!sub || !sub.customer_id) {
      return c.json({ error: 'Customer not found in DB' }, 404)
    }
    
    const paddle = new (await import('@paddle/paddle-node-sdk')).Paddle(c.env.PADDLE_API_KEY, { 
      environment: (await import('@paddle/paddle-node-sdk')).Environment.sandbox 
    })
    
    const session = await paddle.customerPortalSessions.create(sub.customer_id, {
      subscriptionIds: [account.subscription_id]
    })
    
    return c.json({ url: session.url })
  } catch (err) {
    console.error(err)
    return c.json({ error: 'Internal error creating portal session' }, 500)
  }
})

export default app
