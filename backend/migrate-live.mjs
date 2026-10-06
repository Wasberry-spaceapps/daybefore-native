

const LIVE_KEY = 'pdl_live_apikey_01m3jhwkqzk7k92rs1pvrt2ka1_70gqfnWjKJEa3Cb9RqzSNF_ANj';
const API_BASE = 'https://api.paddle.com';

async function req(path, method, body) {
  const res = await fetch(`${API_BASE}${path}`, {
    method,
    headers: {
      'Authorization': `Bearer ${LIVE_KEY}`,
      'Content-Type': 'application/json'
    },
    body: body ? JSON.stringify(body) : undefined
  });
  const data = await res.json();
  if (data.error) throw new Error(JSON.stringify(data.error));
  return data.data;
}

async function migrate() {
  console.log("Creating Product...");
  const product = await req('/products', 'POST', {
    name: "Day Before Sync",
    tax_category: "saas",
    description: "Optional encrypted cloud sync tier",
    type: "standard"
  });
  console.log("Live Product ID:", product.id);

  console.log("Creating Standard Price...");
  const standardPrice = await req('/prices', 'POST', {
    product_id: product.id,
    description: "Standard Monthly",
    name: "Standard Monthly",
    billing_cycle: { interval: "month", frequency: 1 },
    tax_mode: "location",
    unit_price: { amount: "300", currency_code: "USD" },
    unit_price_overrides: [
      { country_codes: ["GB"], unit_price: { amount: "250", currency_code: "GBP" } },
      { country_codes: ["IE"], unit_price: { amount: "300", currency_code: "EUR" } },
      { country_codes: ["AU"], unit_price: { amount: "450", currency_code: "AUD" } }
    ],
    quantity: { minimum: 1, maximum: 100 }
  });
  console.log("Live Standard Price ID:", standardPrice.id);

  console.log("Creating Student Price...");
  const studentPrice = await req('/prices', 'POST', {
    product_id: product.id,
    description: "Student Monthly",
    name: "Student Monthly",
    billing_cycle: { interval: "month", frequency: 1 },
    tax_mode: "location",
    unit_price: { amount: "150", currency_code: "USD" },
    unit_price_overrides: [
      { country_codes: ["GB"], unit_price: { amount: "125", currency_code: "GBP" } },
      { country_codes: ["IE"], unit_price: { amount: "150", currency_code: "EUR" } },
      { country_codes: ["AU"], unit_price: { amount: "225", currency_code: "AUD" } }
    ],
    quantity: { minimum: 1, maximum: 100 }
  });
  console.log("Live Student Price ID:", studentPrice.id);

  console.log("Creating Webhook Destination...");
  const webhook = await req('/notification-settings', 'POST', {
    description: "Day Before Live Webhooks",
    destination: "https://daybefore-backend.officialmutairu.workers.dev/api/webhooks/paddle",
    type: "url",
    subscribed_events: [
      { name: "transaction.completed" },
      { name: "subscription.created" },
      { name: "subscription.updated" },
      { name: "subscription.canceled" },
      { name: "customer.created" },
      { name: "customer.updated" }
    ],
    api_version: 1,
    include_sensitive_fields: false
  });
  console.log("Live Webhook Secret:", webhook.endpoint_secret_key);
}

migrate().catch(console.error);
