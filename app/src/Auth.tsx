// @ts-nocheck
import { useState } from 'react';
import { deriveKey, generateDataKey, generateRecoveryKey, deriveRecoveryKey, wrapDataKey, unwrapDataKey, generateSalt, hashPassword } from './crypto';

const API_URL = (import.meta as any).env.VITE_API_URL || 'https://daybefore-backend.officialmutairu.workers.dev/api';

export default function Auth() {
  const [isLogin, setIsLogin] = useState(true);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [recoveryKeyDisplay, setRecoveryKeyDisplay] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const passwordHash = await hashPassword(password);
      let payload: any = { email, passwordHash };

      let localSalt: Uint8Array | null = null;
      let recoveryKeyStr = '';

      if (!isLogin) {
        localSalt = generateSalt();
        const saltB64 = btoa(String.fromCharCode(...localSalt));
        payload.salt = saltB64;
        
        // V2 Versioned Envelope Generation
        const pwdKey = await deriveKey(password, localSalt);
        const dataKey = await generateDataKey();
        recoveryKeyStr = generateRecoveryKey();
        const recKeyObj = await deriveRecoveryKey(recoveryKeyStr);
        
        payload.wrappedKeyPwd = await wrapDataKey(dataKey, pwdKey);
        payload.wrappedKeyRecovery = await wrapDataKey(dataKey, recKeyObj);
      }

      const res = await fetch(`${API_URL}/auth/${isLogin ? 'login' : 'register'}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Authentication failed');

      localStorage.setItem('daybefore_token', data.token);
      localStorage.setItem('daybefore_salt', data.salt);

      let saltArr = new Uint8Array(16);
      if (data.salt && data.salt !== "null" && data.salt !== "undefined") {
        try {
          const saltBin = atob(data.salt);
          saltArr = new Uint8Array(saltBin.length);
          for(let i=0; i<saltBin.length; i++) saltArr[i] = saltBin.charCodeAt(i);
        } catch (e) { console.error("Failed to parse salt", e); }
      } else {
        const enc = new TextEncoder();
        saltArr = enc.encode("daybefore-salt");
      }
      
      const pwdKey = await deriveKey(password, saltArr);

      if (isLogin) {
        if (data.wrappedKeyPwd) {
          // V2 Login
          const dataKey = await unwrapDataKey(data.wrappedKeyPwd, pwdKey);
          (window as any).e2eKey = dataKey;
          window.location.hash = '#app';
        } else {
          // V1 Legacy Login + Migrate
          (window as any).e2eKey = pwdKey;
          
          recoveryKeyStr = generateRecoveryKey();
          const recKeyObj = await deriveRecoveryKey(recoveryKeyStr);
          const wrappedKeyPwd = await wrapDataKey(pwdKey, pwdKey);
          const wrappedKeyRecovery = await wrapDataKey(pwdKey, recKeyObj);
          
          await fetch(`${API_URL}/auth/migrate-v2`, {
            method: 'POST',
            headers: { 
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${data.token}`
            },
            body: JSON.stringify({ wrappedKeyPwd, wrappedKeyRecovery })
          });
          
          setRecoveryKeyDisplay(recoveryKeyStr);
        }
      } else {
        // Register success
        (window as any).e2eKey = await deriveKey(password, localSalt!); // Wait, we should unwrap or just store dataKey. Let's unwrap to be sure or just hold it.
        // Actually, we generated dataKey above, but it's lost in scope. Let's re-unwrap it.
        const dataKey = await unwrapDataKey(payload.wrappedKeyPwd, pwdKey);
        (window as any).e2eKey = dataKey;
        
        setRecoveryKeyDisplay(recoveryKeyStr);
      }
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  if (recoveryKeyDisplay) {
    return (
      <div className="auth-container" style={{ textAlign: 'center' }}>
        <h2 style={{ fontSize: '1.5rem', marginBottom: '16px', fontWeight: 500 }}>Save Your Recovery Key</h2>
        <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', lineHeight: '1.5' }}>
          This is the ONLY way to recover your journal if you forget your password. We cannot reset it for you.
          Please write it down or save it somewhere safe.
        </p>
        <div style={{ 
          background: 'var(--color-raised, #262321)', 
          padding: '24px', 
          borderRadius: '8px', 
          fontSize: '1.2rem', 
          letterSpacing: '2px',
          fontFamily: 'monospace',
          marginBottom: '32px'
        }}>
          {recoveryKeyDisplay}
        </div>
        <button 
          onClick={() => window.location.hash = '#app'}
          style={{ padding: '12px 24px', background: 'var(--text-primary)', color: 'var(--background, #1a1817)', border: 'none', borderRadius: '4px', cursor: 'pointer', fontWeight: 500 }}>
          I have saved it
        </button>
      </div>
    );
  }

  return (
    <div className="auth-container">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '48px' }}>
        <h1 style={{ fontSize: '2rem', fontWeight: 500, letterSpacing: '0.02em', cursor: 'pointer' }} onClick={() => window.location.hash = ''}>
          Day Before
        </h1>
      </div>

      <h2 style={{ fontSize: '1.2rem', marginBottom: '24px', fontWeight: 500 }}>
        {isLogin ? 'Log In' : 'Create Account'}
      </h2>

      {error && <div style={{ color: '#e74c3c', marginBottom: '16px' }}>{error}</div>}

      <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
        <input 
          type="email" 
          placeholder="Email address"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          style={{ padding: '12px', background: 'transparent', border: '1px solid var(--divider, #36312d)', color: 'var(--text-primary, #e8e4df)', fontSize: '1rem', borderRadius: '4px' }}
        />
        <input 
          type="password" 
          placeholder="Passphrase"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
          style={{ padding: '12px', background: 'transparent', border: '1px solid var(--divider, #36312d)', color: 'var(--text-primary, #e8e4df)', fontSize: '1rem', borderRadius: '4px' }}
        />
        
        <button 
          type="submit" 
          disabled={loading}
          style={{ marginTop: '8px', padding: '12px', background: 'transparent', border: '1px solid var(--text-primary, #e8e4df)', color: 'var(--text-primary, #e8e4df)', fontSize: '1rem', borderRadius: '4px', cursor: loading ? 'not-allowed' : 'pointer' }}>
          {loading ? 'Processing...' : (isLogin ? 'Log In' : 'Register')}
        </button>
      </form>

      <div style={{ marginTop: '24px', textAlign: 'center' }}>
        <button 
          type="button"
          onClick={() => { setIsLogin(!isLogin); setError(''); }}
          style={{ background: 'transparent', border: 'none', color: 'var(--text-secondary, #968d86)', cursor: 'pointer', textDecoration: 'underline' }}>
          {isLogin ? "Don't have an account? Register" : "Already have an account? Log In"}
        </button>
      </div>
    </div>
  );
}
