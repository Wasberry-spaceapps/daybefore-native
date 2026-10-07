import React, { useState, useEffect } from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import Landing from './Landing.tsx'
import Pricing from './Pricing.tsx'
import Auth from './Auth.tsx'
import Legal from './Legal.tsx'
import Design from './Design.tsx'
import { deriveKey, unwrapDataKey } from './crypto'
import './index.css'
import './fonts.css'
import './tokens.css'

const Download = () => <div className="page-container"><h1>Download</h1></div>;
const Signup = () => <div className="page-container"><h1>Signup</h1></div>;
const Forgot = () => (
  <div className="page-container">
    <h1 style={{ fontSize: '1.8rem', marginBottom: '8px' }}>Forgot Your Password?</h1>
    <p style={{ color: 'var(--text-secondary)', marginBottom: '32px', fontFamily: 'var(--font-sans, inherit)' }}>
      <button onClick={() => window.location.hash = ''} style={{ background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', padding: 0, textDecoration: 'underline' }}>← Home</button>
    </p>
    <p style={{ lineHeight: '1.8', marginBottom: '24px' }}>
      Day Before uses end-to-end encryption. Your password never leaves your device in plain form, so we cannot email you a reset link.
    </p>
    <p style={{ lineHeight: '1.8', marginBottom: '24px' }}>
      <strong>If you have your recovery key</strong> — password reset via recovery key is coming soon. In the meantime, contact support.
    </p>
    <p style={{ lineHeight: '1.8', marginBottom: '48px', color: 'var(--text-secondary)' }}>
      <strong style={{ color: 'var(--text-primary)' }}>If you don't have your recovery key</strong> — your encrypted entries cannot be recovered. You can create a new account and start fresh.
    </p>
    <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
      <button onClick={() => window.location.hash = '#auth'} style={{ padding: '12px 24px', border: '1px solid var(--divider, #333)', borderRadius: '4px', cursor: 'pointer' }}>Back to Login</button>
    </div>
  </div>
);
const Reset = () => <div className="page-container"><h1>Reset</h1></div>;
const Verify = () => <div className="page-container"><h1>Verify</h1></div>;
const Account = () => <div className="page-container"><h1>Account</h1></div>;
const Student = () => <div className="page-container"><h1>Student</h1></div>;
const Contact = () => <div className="page-container"><h1>Contact</h1></div>;

function Router() {
  const [hash, setHash] = useState(window.location.hash);

  useEffect(() => {
    const handleHashChange = () => setHash(window.location.hash);
    window.addEventListener('hashchange', handleHashChange);
    return () => window.removeEventListener('hashchange', handleHashChange);
  }, []);

  if (hash === '#app') {
    return <App />;
  } else if (hash === '#pricing') {
    return <Pricing />;
  } else if (hash === '#auth') {
    return <Auth />;
  } else if (hash === '#legal' || hash === '#terms' || hash === '#privacy' || hash === '#refunds') {
    return <Legal />;
  } else if (hash === '#design') {
    return <Design />;
  } else if (hash === '#download') {
    return <Download />;
  } else if (hash === '#signup') {
    return <Signup />;
  } else if (hash === '#forgot') {
    return <Forgot />;
  } else if (hash === '#reset') {
    return <Reset />;
  } else if (hash === '#verify') {
    return <Verify />;
  } else if (hash === '#account') {
    return <Account />;
  } else if (hash === '#student') {
    return <Student />;
  } else if (hash === '#contact') {
    return <Contact />;
  }

  return <Landing />;
}


function AppWrapper() {
  const [locked, setLocked] = useState(false);
  const [lockPass, setLockPass] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    const handler = () => {
      if (document.visibilityState === 'hidden' && localStorage.getItem('daybefore_token')) {
        (window as any).e2eKey = null;
        setLocked(true);
      }
    };
    document.addEventListener('visibilitychange', handler);
    return () => document.removeEventListener('visibilitychange', handler);
  }, []);

  if (locked) {
    return (
      <div style={{
        position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
        background: 'var(--color-ground, var(--bg-color))', zIndex: 999999,
        display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
        color: 'var(--text-primary)', fontFamily: 'var(--font-display)'
      }}>
        <h1 style={{fontSize: '2rem', marginBottom: '8px'}}>Day Before</h1>
        <p style={{color: 'var(--text-secondary)', marginBottom: '32px', fontFamily: 'var(--font-sans)'}}>Enter your password to open your journal.</p>
        <div style={{display: 'flex', gap: '8px'}}>
          <input
            type="password"
            autoComplete="new-password"
            value={lockPass}
            onChange={e => setLockPass(e.target.value)}
            onKeyDown={e => { if(e.key === 'Enter') handleUnlock() }}
            style={{padding: '12px', borderRadius: '4px', border: '1px solid var(--divider)', background: 'transparent', color: 'inherit'}}
            autoFocus
          />
          <button 
            onClick={handleUnlock}
            style={{padding: '12px 24px', borderRadius: '4px', background: 'var(--text-primary)', color: 'var(--color-ground, var(--bg-color))', border: 'none', cursor: 'pointer', fontFamily: 'var(--font-sans)'}}
          >Unlock</button>
        </div>
        {error && <p style={{color: 'var(--color-danger, #e57373)', fontFamily: 'var(--font-sans)', marginTop: '16px'}}>{error}</p>}
        <button
          onClick={() => { setLocked(false); window.location.hash = ''; }}
          style={{marginTop: '32px', color: 'var(--text-secondary)', fontFamily: 'var(--font-sans)', background: 'none', border: 'none', cursor: 'pointer', fontSize: '0.9rem', textDecoration: 'underline'}}
        >← Go Home</button>
      </div>
    );
  }

  async function handleUnlock() {
    try {
      const salt = localStorage.getItem('daybefore_salt');
      const wrappedKeyPwd = localStorage.getItem('daybefore_wrappedKeyPwd');
      if (!salt || !wrappedKeyPwd) {
        setLocked(false);
        window.location.hash = '#auth';
        return;
      }
      let saltArr = new Uint8Array(16);
      if (salt.includes(',')) {
        saltArr = new Uint8Array(salt.split(',').map(Number));
      } else {
        const saltBin = atob(salt);
        saltArr = new Uint8Array(saltBin.length);
        for(let i=0; i<saltBin.length; i++) saltArr[i] = saltBin.charCodeAt(i);
      }

      const pwdKey = await deriveKey(lockPass, saltArr);
      const dataKey = await unwrapDataKey(wrappedKeyPwd, pwdKey);
      (window as any).e2eKey = dataKey;
      setLocked(false);
      setError('');
      setLockPass('');
    } catch (e) {
      setError('That password did not match.');
    }
  }

  return <Router />;
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <AppWrapper />
  </React.StrictMode>,
)

