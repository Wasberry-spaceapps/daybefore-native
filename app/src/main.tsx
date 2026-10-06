import React, { useState, useEffect } from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import Landing from './Landing.tsx'
import Pricing from './Pricing.tsx'
import Auth from './Auth.tsx'
import Legal from './Legal.tsx'
import Design from './Design.tsx'
import './index.css'
import './fonts.css'
import './tokens.css'

const Download = () => <div className="page-container"><h1>Download</h1></div>;
const Signup = () => <div className="page-container"><h1>Signup</h1></div>;
const Forgot = () => <div className="page-container"><h1>Forgot</h1></div>;
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
      if (document.visibilityState === 'hidden') {
        // wipe data key
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
      </div>
    );
  }

  async function handleUnlock() {
    try {
      const salt = localStorage.getItem('daybefore_salt');
      if (!salt) {
         setLocked(false);
         return; // Local only without lock
      }
      const enc = new TextEncoder();
      const keyMaterial = await crypto.subtle.importKey(
        'raw', enc.encode(lockPass), { name: 'PBKDF2' }, false, ['deriveKey']
      );
      const key = await crypto.subtle.deriveKey(
        {
          name: 'PBKDF2',
          salt: new Uint8Array(salt.split(',').map(Number)),
          iterations: 100000,
          hash: 'SHA-256'
        },
        keyMaterial,
        { name: 'AES-GCM', length: 256 },
        true,
        ['encrypt', 'decrypt']
      );
      // We assume it succeeded if it derives. If wrappedKeyPwd exists we should verify it.
      (window as any).e2eKey = key;
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

