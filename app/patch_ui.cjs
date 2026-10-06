const fs = require('fs');
let code = fs.readFileSync('src/Pricing.tsx', 'utf8');
code = code.replace(
  "<button onClick={() => window.location.hash = ''} style={{ color: 'var(--text-secondary)' }}>Back to Home</button>",
  `<div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
            <button onClick={() => setRegion(region === 'nigeria' ? 'rest_of_world' : 'nigeria')} style={{ color: 'var(--accent)', fontSize: '0.8rem', border: '1px solid var(--divider)', padding: '4px 8px', borderRadius: '4px' }}>
              Test: {region === 'nigeria' ? 'Paystack' : 'Paddle'}
            </button>
            <button onClick={() => window.location.hash = ''} style={{ color: 'var(--text-secondary)' }}>Back to Home</button>
          </div>`
);
fs.writeFileSync('src/Pricing.tsx', code);
