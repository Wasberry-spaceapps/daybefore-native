const fs = require('fs');

// Patch App.tsx
const pathApp = './src/App.tsx';
let code = fs.readFileSync(pathApp, 'utf8');

const coreSectionStr = `              </section>
            </div>
  
            <div className="panel-footer"`;

const issuesSection = `              </section>

              <section className={\`sidebar-section \${issuesCollapsed ? 'collapsed' : ''}\`}>
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
                          className={\`list-item \${activeView.type === 'issue' && activeView.id === issue.id ? 'active' : ''}\`}
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
  
            <div className="panel-footer"`;

code = code.replace(coreSectionStr, issuesSection);
fs.writeFileSync(pathApp, code);

// Patch db.ts
const pathDb = './src/db.ts';
let dbCode = fs.readFileSync(pathDb, 'utf8');
dbCode = dbCode.replace(`interface Issue {
  id: string;
  name: string;
  isArchived: boolean;
  createdAt: number;
  updatedAt: number;
}`, `interface Issue {
  id: string;
  name: string;
  content?: string;
  isArchived: boolean;
  createdAt: number;
  updatedAt: number;
}`);
fs.writeFileSync(pathDb, dbCode);

console.log('Patched App.tsx and db.ts');
