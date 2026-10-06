const fs = require('fs');

// 1. Rewrite index.css mobile queries
let css = fs.readFileSync('src/index.css', 'utf8');

const oldMedia = `@media (max-width: 768px) {
  .page-container, .auth-container {
    padding: 32px 16px;
  }
  .app-container {
    flex-direction: column;
  }
  .left-panel {
    width: 100%;
    min-width: 100%;
    height: 40vh;
    border-right: none;
    border-bottom: 1px solid var(--divider);
    padding: 16px;
  }
  .main-content {
    padding: 16px;
    height: 60vh;
  }
  .panel-footer {
    margin-top: 12px;
    padding-top: 12px;
    flex-direction: row;
    justify-content: space-between;
    gap: 16px;
  }
  .editor-area {
    padding-bottom: 40px;
  }
}`;

const newMedia = `@media (max-width: 768px) {
  .page-container, .auth-container {
    padding: 24px 16px;
  }
  .app-container {
    flex-direction: row;
    position: relative;
    overflow: hidden;
  }
  .left-panel {
    position: fixed;
    top: 0;
    left: 0;
    width: 280px;
    height: 100vh;
    z-index: 100;
    background: var(--bg-color);
    box-shadow: 4px 0 24px rgba(0,0,0,0.8);
    border-right: 1px solid var(--divider);
    padding: 24px 16px;
  }
  .main-content {
    width: 100vw;
    height: 100vh;
    padding: 16px;
    padding-top: 64px;
  }
  .restore-container {
    position: fixed;
    top: 16px;
    left: 16px;
    z-index: 90;
  }
  .restore-btn {
    font-size: 1.5rem !important;
    background: var(--divider) !important;
    color: var(--text-primary) !important;
    width: 44px;
    height: 44px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
  }
  .collapse-btn {
    font-size: 1.2rem !important;
    background: var(--divider) !important;
    color: var(--text-primary) !important;
    width: 40px;
    height: 40px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .editor-area {
    padding-bottom: 24px;
  }
  .editor-toolbar {
    padding-bottom: 16px;
  }
  .main-textarea {
    padding: 16px 0;
  }
  .panel-footer {
    margin-top: 12px;
    padding-top: 12px;
  }
}`;

// Note: Replacing exact strings can be fragile if there are minor spacing diffs.
// We'll use a regex to replace everything from @media (max-width: 768px) { down to the end of the file.
css = css.replace(/@media \(max-width: 768px\) \{[\s\S]*\}\s*$/, newMedia);
fs.writeFileSync('src/index.css', css);

// 2. Rewrite App.tsx to use Hamburger / Close icons instead of < and >
let app = fs.readFileSync('src/App.tsx', 'utf8');

// Change the collapse button
app = app.replace(
  /<button onClick=\{\(\) => setLeftPanelCollapsed\(true\)\} className="collapse-btn text-btn" style=\{\{ fontSize: '1\.2rem' \}\}>\s*&lt;\s*<\/button>/g,
  `<button onClick={() => setLeftPanelCollapsed(true)} className="collapse-btn text-btn" style={{ fontSize: '1.2rem' }}>✕</button>`
);

// Change the restore button
app = app.replace(
  /<button onClick=\{\(\) => setLeftPanelCollapsed\(false\)\} className="restore-btn text-btn" style=\{\{ fontSize: '1\.2rem' \}\}>\s*&gt;\s*<\/button>/g,
  `<button onClick={() => setLeftPanelCollapsed(false)} className="restore-btn text-btn" style={{ fontSize: '1.5rem' }}>☰</button>`
);

fs.writeFileSync('src/App.tsx', app);
console.log("Mobile layout refined!");
