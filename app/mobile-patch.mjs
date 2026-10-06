import fs from 'fs';

// 1. Update index.css
let css = fs.readFileSync('src/index.css', 'utf8');
if (!css.includes('@media (max-width: 768px)')) {
  css += `\n
/* Mobile Responsiveness */
.page-container {
  padding: 64px;
  max-width: 800px;
  margin: 0 auto;
  line-height: 1.6;
}
.auth-container {
  padding: 64px;
  max-width: 400px;
  margin: 0 auto;
  line-height: 1.6;
}
.footer-links {
  margin-top: 64px;
  border-top: 1px solid var(--divider);
  padding-top: 24px;
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
  font-size: 0.8rem;
}

@media (max-width: 768px) {
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
}
`;
  fs.writeFileSync('src/index.css', css);
}

// 2. Patch Landing.tsx
let landing = fs.readFileSync('src/Landing.tsx', 'utf8');
landing = landing.replace(
  /<div style=\{\{\s*padding:\s*'64px',\s*maxWidth:\s*'800px',\s*margin:\s*'0 auto',\s*lineHeight:\s*'1\.6'\s*\}\}>/,
  `<div className="page-container">`
);
landing = landing.replace(
  /<div style=\{\{\s*marginTop:\s*'64px',\s*borderTop:\s*'1px solid var\(--divider\)',\s*paddingTop:\s*'24px',\s*display:\s*'flex',\s*gap:\s*'24px',\s*fontSize:\s*'0\.8rem'\s*\}\}>/,
  `<div className="footer-links">`
);
fs.writeFileSync('src/Landing.tsx', landing);

// 3. Patch Pricing.tsx
let pricing = fs.readFileSync('src/Pricing.tsx', 'utf8');
pricing = pricing.replace(
  /<div style=\{\{\s*padding:\s*'64px',\s*maxWidth:\s*'800px',\s*margin:\s*'0 auto',\s*lineHeight:\s*'1\.6'\s*\}\}>/,
  `<div className="page-container">`
);
fs.writeFileSync('src/Pricing.tsx', pricing);

// 4. Patch Auth.tsx
let auth = fs.readFileSync('src/Auth.tsx', 'utf8');
auth = auth.replace(
  /<div style=\{\{\s*padding:\s*'64px',\s*maxWidth:\s*'400px',\s*margin:\s*'0 auto',\s*lineHeight:\s*'1\.6'\s*\}\}>/,
  `<div className="auth-container">`
);
fs.writeFileSync('src/Auth.tsx', auth);
console.log("Mobile responsiveness patched!");
