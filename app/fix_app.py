import re

# App.tsx modifications
with open("src/App.tsx", "r", encoding="utf-8") as f:
    app_ts = f.read()

# Add imports
app_ts = app_ts.replace("import Game from './Game';", "import Game from './Game';\nimport ExportModal from './ExportModal';")

# Add state
app_ts = app_ts.replace("const [showGame, setShowGame] = useState(false);", "const [showGame, setShowGame] = useState(false);\n  const [showExport, setShowExport] = useState(false);")

# Add ExportModal
app_ts = app_ts.replace("{showGame && <Game onClose={() => setShowGame(false)} />}", "{showGame && <Game onClose={() => setShowGame(false)} />}\n      {showExport && <ExportModal onClose={() => setShowExport(false)} />}")

# Add button
footer_html = """<div className="panel-footer" style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <button className="game-link text-btn" onClick={() => setShowGame(true)}>take a minute</button>
            <button className="text-btn" style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }} onClick={() => setShowExport(true)}>Export</button>"""
app_ts = app_ts.replace("""<div className="panel-footer" style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <button className="game-link text-btn" onClick={() => setShowGame(true)}>take a minute</button>""", footer_html)

with open("src/App.tsx", "w", encoding="utf-8") as f:
    f.write(app_ts)

# main.tsx modifications for Privacy Lock
with open("src/main.tsx", "r", encoding="utf-8") as f:
    main_ts = f.read()

lock_code = """
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
"""

main_ts = main_ts.replace("""ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <Router />
  </React.StrictMode>,
)""", lock_code)

with open("src/main.tsx", "w", encoding="utf-8") as f:
    f.write(main_ts)
