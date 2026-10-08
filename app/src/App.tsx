import { useState, useEffect } from 'react';
import { useLiveQuery } from 'dexie-react-hooks';
import { db } from './db';
import Game from './Game';
import ExportModal from './ExportModal';
import { syncDatabase } from './sync';
import {
  markBackupDirty, startBackupScheduler, setupBackupFolder,
  exportAllAccountData, encryptBackup, mirrorToOPFS, requestPersistentStorage
} from './redundancy';
import { getBackupHandle } from './registry';
import './index.css';

function generateId() {
  return crypto.randomUUID();
}

function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.warn(error);
      return initialValue;
    }
  });

  const setValue = (value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.warn(error);
    }
  };

  return [storedValue, setValue] as const;
}

type ViewContext = 
  | { type: 'journal', id: string | null }
  | { type: 'core', id: string }
  | { type: 'issue', id: string };

function formatDate(ts: number) {
  const d = new Date(ts);
  const pad = (n: number) => n.toString().padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}${pad(d.getMinutes())}`;
}

export default function App() {
  const [leftPanelCollapsed, setLeftPanelCollapsed] = useLocalStorage('daybefore_leftPanel', false);
  const [journalCollapsed, setJournalCollapsed] = useLocalStorage('daybefore_journalCol', false);
  const [coreCollapsed, setCoreCollapsed] = useLocalStorage('daybefore_coreCol', false);
  const [issuesCollapsed, setIssuesCollapsed] = useLocalStorage('daybefore_issuesCol', false);

  const [activeView, setActiveView] = useState<ViewContext>({ type: 'journal', id: null });
  const [showGame, setShowGame] = useState(false);
  const [showExport, setShowExport] = useState(false);
  const [showBackupPrompt, setShowBackupPrompt] = useState(false);

  // Editor states
  const [draftContent, setDraftContent] = useState('');
  const [newItemName, setNewItemName] = useState('');
  const [creatingType, setCreatingType] = useState<'core' | 'issue' | null>(null);

  // Queries
  const journalEntries = useLiveQuery(() => db.journalEntries.orderBy('createdAt').reverse().toArray());
  const corePoints = useLiveQuery(() => db.corePoints.orderBy('createdAt').toArray());
  const issues = useLiveQuery(() => db.issues.orderBy('createdAt').toArray());

  const activeCorePoint = useLiveQuery(() => {
    if (activeView.type === 'core') return db.corePoints.get(activeView.id);
    return undefined;
  }, [activeView]);

  const activeIssue = useLiveQuery(() => {
    if (activeView.type === 'issue') return db.issues.get(activeView.id);
    return undefined;
  }, [activeView]);

  const activeJournalEntry = useLiveQuery(() => {
    if (activeView.type === 'journal' && activeView.id) return db.journalEntries.get(activeView.id);
    return undefined;
  }, [activeView]);

  const runSync = () => {
    const token = localStorage.getItem('daybefore_token');
    const key = (window as any).e2eKey;
    if (token && key) {
      syncDatabase(token, key).catch(console.error);
    }
  };

  useEffect(() => {
    const token = localStorage.getItem('daybefore_token');
    if (!token) {
      window.location.hash = '#auth';
      return;
    }
    runSync();

    // Request persistent storage so the browser won't evict our IndexedDB
    requestPersistentStorage();

    // Start the backup scheduler
    const accountId = localStorage.getItem('daybefore_email') ?? 'local';
    const e2eKey = (window as any).e2eKey as CryptoKey | undefined;
    if (e2eKey) {
      const exportFn = async () => {
        const allData = await exportAllAccountData(db);
        return encryptBackup(allData, e2eKey, accountId);
      };
      startBackupScheduler(accountId, exportFn);
    }

    // Show backup folder prompt if File System Access is available and no folder chosen yet
    getBackupHandle(accountId).then(handle => {
      if (!handle && 'showDirectoryPicker' in window) {
        setShowBackupPrompt(true);
      }
    });
  }, []);

  // Load content when active view changes
  useEffect(() => {
    if (activeView.type === 'journal' && activeJournalEntry) {
      setDraftContent(activeJournalEntry.content);
    } else if (activeView.type === 'core' && activeCorePoint) {
      setDraftContent(activeCorePoint.content);
    } else if (activeView.type === 'issue' && activeIssue) {
      setDraftContent(activeIssue.content || '');
    } else if (activeView.type === 'journal' && !activeView.id) {
      setDraftContent('');
    }
  }, [activeView, activeJournalEntry, activeCorePoint, activeIssue]);

  // Autosave + OPFS mirror
  const accountId = localStorage.getItem('daybefore_email') ?? 'local';
  useEffect(() => {
    const timeout = setTimeout(async () => {
      if (activeView.type === 'journal' && activeView.id) {
        const e = await db.journalEntries.get(activeView.id);
        if (e && e.content !== draftContent) {
          const updated = { ...e, content: draftContent, updatedAt: Date.now() };
          await db.journalEntries.update(activeView.id, { content: draftContent, updatedAt: updated.updatedAt });
          mirrorToOPFS(accountId, 'journalEntries', updated);
          markBackupDirty();
          runSync();
        }
      } else if (activeView.type === 'core') {
        const e = await db.corePoints.get(activeView.id);
        if (e && e.content !== draftContent) {
          const updated = { ...e, content: draftContent, updatedAt: Date.now() };
          await db.corePoints.update(activeView.id, { content: draftContent, updatedAt: updated.updatedAt });
          mirrorToOPFS(accountId, 'corePoints', updated);
          markBackupDirty();
          runSync();
        }
      } else if (activeView.type === 'issue') {
        const e = await db.issues.get(activeView.id);
        if (e && e.content !== draftContent) {
          const updated = { ...e, content: draftContent, updatedAt: Date.now() };
          await db.issues.update(activeView.id, { content: draftContent, updatedAt: updated.updatedAt });
          mirrorToOPFS(accountId, 'issues', updated);
          markBackupDirty();
          runSync();
        }
      }
    }, 1000);
    return () => clearTimeout(timeout);
  }, [draftContent, activeView]);

  const handleNewJournal = async () => {
    const id = generateId();
    await db.journalEntries.add({
      id,
      content: '',
      createdAt: Date.now(),
      updatedAt: Date.now()
    });
    setActiveView({ type: 'journal', id });
  };

  const handleDeleteJournal = async (id: string) => {
    await db.journalEntries.delete(id);
    setActiveView({ type: 'journal', id: null });
    runSync();
  };

  const handleCreateNew = async () => {
    if (!newItemName.trim() || !creatingType) return;
    
    if (creatingType === 'core') {
      const id = generateId();
      await db.corePoints.add({
        id,
        name: newItemName,
        content: '',
        createdAt: Date.now(),
        updatedAt: Date.now()
      });
      setActiveView({ type: 'core', id });
    } else if (creatingType === 'issue') {
      const id = generateId();
      await db.issues.add({
        id,
        name: newItemName,
        isArchived: false,
        createdAt: Date.now(),
        updatedAt: Date.now()
      });
      setActiveView({ type: 'issue', id });
    }
    
    setCreatingType(null);
    setNewItemName('');
    runSync();
  };

  return (
    <div className="app-container">
      {showGame && <Game onClose={() => setShowGame(false)} />}
      {showExport && <ExportModal onClose={() => setShowExport(false)} />}

      {showBackupPrompt && (
        <div style={{
          position: 'fixed', bottom: '24px', left: '50%', transform: 'translateX(-50%)',
          background: 'var(--bg-color)', border: '1px solid var(--divider)', borderRadius: '8px',
          padding: '16px 24px', zIndex: 9999, maxWidth: '480px', width: 'calc(100vw - 48px)',
          boxShadow: '0 8px 32px rgba(0,0,0,0.5)', fontFamily: 'var(--font-sans, inherit)'
        }}>
          <p style={{ marginBottom: '12px', fontSize: '0.95rem' }}>
            <strong>Keep a backup of your journal.</strong> Choose a folder where Day Before can save an encrypted copy. Your entries stay safe even if you clear your browser data.
          </p>
          <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
            <button
              onClick={() => setShowBackupPrompt(false)}
              style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', background: 'none', border: 'none', cursor: 'pointer' }}>
              Not now
            </button>
            <button
              onClick={async () => {
                const chosen = await setupBackupFolder(accountId);
                if (chosen) setShowBackupPrompt(false);
              }}
              style={{ padding: '8px 16px', background: 'var(--text-primary)', color: 'var(--bg-color)', borderRadius: '4px', border: 'none', cursor: 'pointer', fontSize: '0.9rem' }}>
              Choose folder
            </button>
          </div>
        </div>
      )}
      
      {!leftPanelCollapsed && (
        <aside className="left-panel">
          <div className="panel-header">
            <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}><button onClick={() => setLeftPanelCollapsed(true)} className="collapse-btn text-btn" style={{ fontSize: '1.2rem' }}>&#x2715;</button><a href="#" className="text-btn" style={{ textDecoration: 'none', color: 'var(--text-secondary)' }}>Home</a></div>
            <button onClick={handleNewJournal} className="text-btn" style={{ fontWeight: 'bold', color: 'var(--accent)' }}>
              New Entry
            </button>
          </div>
          
          <div className="sections">
            <section className={`sidebar-section ${journalCollapsed ? 'collapsed' : ''}`}>
              <div className="section-header">
                <h2>JOURNAL HISTORY</h2>
                <button onClick={() => setJournalCollapsed(!journalCollapsed)} className="toggle-btn text-btn">
                  {journalCollapsed ? 'show' : 'hide'}
                </button>
              </div>
              {!journalCollapsed && (
                <div className="section-content scrollable">
                  <div className="list-items">
                    {journalEntries?.map(entry => {
                      const snippet = entry.content.slice(0, 30) || '...';
                      const isActive = activeView.type === 'journal' && activeView.id === entry.id;
                      return (
                        <div 
                          key={entry.id} 
                          className={`list-item ${isActive ? 'active' : ''}`}
                          onClick={() => setActiveView({ type: 'journal', id: entry.id! })}
                        >
                          <div style={{ color: isActive ? 'var(--accent)' : 'var(--text-secondary)' }}>{formatDate(entry.createdAt)}</div>
                          <div style={{ fontSize: '0.9rem' }}>{snippet}</div>
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}
            </section>

            <section className={`sidebar-section ${coreCollapsed ? 'collapsed' : ''}`}>
              <div className="section-header">
                <h2>CORE POINTS</h2>
                <div style={{display: 'flex', gap: '8px'}}>
                  <button onClick={() => setCreatingType('core')} className="text-btn">+</button>
                  <button onClick={() => setCoreCollapsed(!coreCollapsed)} className="toggle-btn text-btn">
                    {coreCollapsed ? 'show' : 'hide'}
                  </button>
                </div>
              </div>
              {!coreCollapsed && (
                <div className="section-content scrollable">
                  {creatingType === 'core' && (
                    <div className="create-inline">
                      <input 
                        autoFocus
                        placeholder="Name..." 
                        value={newItemName}
                        onChange={e => setNewItemName(e.target.value)}
                        onKeyDown={e => e.key === 'Enter' ? handleCreateNew() : e.key === 'Escape' ? setCreatingType(null) : null}
                        onBlur={() => setCreatingType(null)}
                      />
                    </div>
                  )}
                  <div className="list-items">
                    {corePoints?.map(pt => (
                      <div 
                        key={pt.id} 
                        className={`list-item ${activeView.type === 'core' && activeView.id === pt.id ? 'active' : ''}`}
                        onClick={() => setActiveView({ type: 'core', id: pt.id! })}
                      >
                        <div style={{ fontWeight: 'bold' }}>{pt.name}</div>
                        <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                          {pt.content.slice(0, 30) || '...'}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
                          </section>

              <section className={`sidebar-section ${issuesCollapsed ? 'collapsed' : ''}`}>
                <div className="section-header">
                  <h2>ISSUES</h2>
                  <div style={{display: 'flex', gap: '8px'}}>
                    <button onClick={() => setCreatingType('issue')} className="text-btn">+</button>
                    <button onClick={() => setIssuesCollapsed(!issuesCollapsed)} className="toggle-btn text-btn">
                      {issuesCollapsed ? 'show' : 'hide'}
                    </button>
                  </div>
                </div>
                {!issuesCollapsed && (
                  <div className="section-content scrollable">
                    {creatingType === 'issue' && (
                      <div className="create-inline">
                        <input 
                          autoFocus
                          placeholder="Issue name..." 
                          value={newItemName}
                          onChange={e => setNewItemName(e.target.value)}
                          onKeyDown={e => e.key === 'Enter' ? handleCreateNew() : e.key === 'Escape' ? setCreatingType(null) : null}
                          onBlur={() => setCreatingType(null)}
                        />
                      </div>
                    )}
                    <div className="list-items">
                      {issues?.filter(issue => !issue.isArchived).map(issue => (
                        <div 
                          key={issue.id} 
                          className={`list-item ${activeView.type === 'issue' && activeView.id === issue.id ? 'active' : ''}`}
                          onClick={() => setActiveView({ type: 'issue', id: issue.id! })}
                        >
                          <div style={{ fontWeight: 'bold' }}>{issue.name}</div>
                          <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                            {issue.content ? (issue.content.slice(0, 30) || '...') : '...'}
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </section>
            </div>
  
            <div className="panel-footer" style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <button className="game-link text-btn" onClick={() => setShowGame(true)}>take a minute</button>
            <button className="text-btn" style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }} onClick={() => setShowExport(true)}>Export</button>
            <button 
              className="text-btn" 
              style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}
              onClick={async () => {
                if (localStorage.getItem('daybefore_token')) {
                  if (confirm('Log out? Your entries remain on this device.')) {
                    localStorage.removeItem('daybefore_token');
                    localStorage.removeItem('daybefore_salt');
                    localStorage.removeItem('daybefore_wrappedKeyPwd');
                    localStorage.removeItem('daybefore_email');
                    (window as any).e2eKey = null;
                    window.location.reload();
                  }
                } else {
                  window.location.hash = '#auth';
                }
              }}
            >
              {localStorage.getItem('daybefore_token') ? 'Log Out' : 'Sign In / Sync'}
            </button>
          </div>
        </aside>
      )}

      <main className="main-content">
        {leftPanelCollapsed && (
          <div className="restore-container">
            <button onClick={() => setLeftPanelCollapsed(false)} className="restore-btn text-btn" style={{ fontSize: '1.5rem' }}>☰</button>
          </div>
        )}
        <div className="editor-area">
          {activeView.type === 'journal' && activeView.id && activeJournalEntry ? (
            <>
              <div className="editor-toolbar">
                <span className="editor-title">{formatDate(activeJournalEntry.createdAt).replace(' ', '_')}.md</span>
                <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
                  <button onClick={() => handleDeleteJournal(activeJournalEntry.id!)} title="Delete Entry" style={{ fontSize: '1.2rem' }}>
                    🗑️
                  </button>
                  <span style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>Autosaved</span>
                </div>
              </div>
              <textarea
                value={draftContent}
                onChange={e => setDraftContent(e.target.value)}
                autoFocus
                className="main-textarea"
              />
            </>
          ) : activeView.type === 'core' && activeCorePoint ? (
             <>
              <div className="editor-toolbar">
                <input
                  className="editor-title-input"
                  value={activeCorePoint.name}
                  onChange={async e => {
                    await db.corePoints.update(activeCorePoint.id!, { name: e.target.value, updatedAt: Date.now() });
                    runSync();
                  }}
                  style={{ background: 'transparent', border: 'none', outline: 'none', color: 'inherit', fontWeight: 'bold', fontSize: '1.2rem' }}
                />
                <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
                  <button onClick={async () => {
                    if (confirm('Delete this core point?')) {
                      await db.corePoints.delete(activeCorePoint.id!);
                      setActiveView({ type: 'core', id: '' });
                      runSync();
                    }
                  }} title="Delete Core Point" className="text-btn" style={{ fontSize: '1.2rem' }}>
                    🗑️
                  </button>
                  <span style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>Autosaved</span>
                </div>
              </div>
              <textarea
                value={draftContent}
                onChange={e => setDraftContent(e.target.value)}
                autoFocus
                className="main-textarea"
              />
            </>
          ) : activeView.type === 'issue' && activeIssue ? (
             <>
              <div className="editor-toolbar">
                <input
                  className="editor-title-input"
                  value={activeIssue.name}
                  onChange={async e => {
                    await db.issues.update(activeIssue.id!, { name: e.target.value, updatedAt: Date.now() });
                    runSync();
                  }}
                  style={{ background: 'transparent', border: 'none', outline: 'none', color: 'inherit', fontWeight: 'bold', fontSize: '1.2rem' }}
                />
                <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
                  <button onClick={async () => {
                    if (confirm('Delete this issue?')) {
                      await db.issues.delete(activeIssue.id!);
                      setActiveView({ type: 'issue', id: '' });
                      runSync();
                    }
                  }} title="Delete Issue" className="text-btn" style={{ fontSize: '1.2rem' }}>
                    🗑️
                  </button>
                  <span style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>Autosaved</span>
                </div>
              </div>
              <textarea
                value={draftContent}
                onChange={e => setDraftContent(e.target.value)}
                autoFocus
                className="main-textarea"
              />
            </>
          ) : (
            <div className="empty-state">
              {activeView.type === 'journal' && (
                <button onClick={handleNewJournal} className="text-btn" style={{ color: 'var(--accent)', fontSize: '1.2rem' }}>
                  + Create New Entry
                </button>
              )}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

