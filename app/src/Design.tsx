// @ts-nocheck
import React, { useState } from 'react';
import './tokens.css';

export default function Design() {
  const [theme, setTheme] = useState<'light' | 'dark'>('dark');

  const toggleTheme = () => setTheme(t => t === 'dark' ? 'light' : 'dark');

  return (
    <div data-theme={theme} style={{ 
      background: 'var(--color-ground)', 
      color: 'var(--color-text)', 
      minHeight: '100vh',
      fontFamily: 'var(--font-sans)',
      padding: '48px',
      transition: 'background 200ms ease-out, color 200ms ease-out'
    }}>
      <div style={{ maxWidth: '800px', margin: '0 auto' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '48px' }}>
          <h1 style={{ fontFamily: 'var(--font-display)', fontSize: 'var(--text-h1)', margin: 0 }}>Design System</h1>
          <button 
            onClick={toggleTheme}
            style={{ 
              background: 'var(--color-raised)', 
              color: 'var(--color-text)', 
              border: '1px solid var(--color-hairline)',
              padding: '8px 16px',
              borderRadius: 'var(--radius-small)',
              cursor: 'pointer'
            }}
          >
            Toggle {theme === 'dark' ? 'Light' : 'Dark'}
          </button>
        </div>

        <section style={{ marginBottom: '48px' }}>
          <h2 style={{ fontSize: 'var(--text-h2)', marginBottom: '24px', borderBottom: '1px solid var(--color-hairline)', paddingBottom: '16px' }}>Typography</h2>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div style={{ fontFamily: 'var(--font-display)', fontSize: 'var(--text-h1)' }}>Newsreader Display H1</div>
            <div style={{ fontFamily: 'var(--font-display)', fontSize: 'var(--text-h2)' }}>Newsreader Display H2</div>
            <div style={{ fontFamily: 'var(--font-display)', fontSize: 'var(--text-h3)' }}>Newsreader Display H3</div>
            <div style={{ fontFamily: 'var(--font-sans)', fontSize: 'var(--text-body)' }}>Inter Sans Body</div>
            <div style={{ fontFamily: 'var(--font-sans)', fontSize: 'var(--text-small)' }}>Inter Sans Small</div>
          </div>
        </section>

        <section style={{ marginBottom: '48px' }}>
          <h2 style={{ fontSize: 'var(--text-h2)', marginBottom: '24px', borderBottom: '1px solid var(--color-hairline)', paddingBottom: '16px' }}>Buttons</h2>
          <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
            <button style={{
              background: 'var(--color-text)',
              color: 'var(--color-ground)',
              border: 'none',
              padding: '12px 24px',
              borderRadius: 'var(--radius-small)',
              fontWeight: 500,
              cursor: 'pointer'
            }}>Primary Button</button>
            <button style={{
              background: 'transparent',
              color: 'var(--color-text)',
              border: '1px solid var(--color-hairline)',
              padding: '12px 24px',
              borderRadius: 'var(--radius-small)',
              fontWeight: 500,
              cursor: 'pointer'
            }}>Secondary Button</button>
            <button style={{
              background: 'transparent',
              color: 'var(--color-danger)',
              border: '1px solid var(--color-hairline)',
              padding: '12px 24px',
              borderRadius: 'var(--radius-small)',
              fontWeight: 500,
              cursor: 'pointer'
            }}>Danger Button</button>
            <button style={{
              background: 'transparent',
              color: 'var(--color-text)',
              border: 'none',
              padding: '12px 24px',
              fontWeight: 500,
              cursor: 'pointer'
            }}>Quiet Button</button>
          </div>
        </section>

        <section style={{ marginBottom: '48px' }}>
          <h2 style={{ fontSize: 'var(--text-h2)', marginBottom: '24px', borderBottom: '1px solid var(--color-hairline)', paddingBottom: '16px' }}>Inputs</h2>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', maxWidth: '400px' }}>
            <input 
              type="text" 
              placeholder="Text input..." 
              style={{
                background: 'var(--color-raised)',
                border: 'none',
                color: 'var(--color-text)',
                padding: '16px',
                borderRadius: 'var(--radius-small)',
                fontSize: 'var(--text-body)',
                outline: 'none'
              }}
            />
            <textarea 
              placeholder="Text area..." 
              rows={4}
              style={{
                background: 'var(--color-raised)',
                border: 'none',
                color: 'var(--color-text)',
                padding: '16px',
                borderRadius: 'var(--radius-small)',
                fontSize: 'var(--text-body)',
                fontFamily: 'var(--font-display)',
                outline: 'none',
                resize: 'vertical'
              }}
            />
          </div>
        </section>

        <section style={{ marginBottom: '48px' }}>
          <h2 style={{ fontSize: 'var(--text-h2)', marginBottom: '24px', borderBottom: '1px solid var(--color-hairline)', paddingBottom: '16px' }}>Cards & Layout</h2>
          <div style={{
            background: 'var(--color-raised)',
            border: '1px solid var(--color-hairline)',
            borderRadius: 'var(--radius-large)',
            padding: '32px'
          }}>
            <h3 style={{ margin: '0 0 16px 0', fontSize: 'var(--text-h3)', fontFamily: 'var(--font-display)' }}>Card Title</h3>
            <p style={{ margin: 0, color: 'var(--color-muted)' }}>This is a card component showcasing the raised background and hairline border.</p>
          </div>
        </section>
        <section style={{ marginBottom: '48px' }}>
          <h2 style={{ fontSize: 'var(--text-h2)', marginBottom: '24px', borderBottom: '1px solid var(--color-hairline)', paddingBottom: '16px' }}>Controls & Pills</h2>
          <div style={{ display: 'flex', gap: '24px', alignItems: 'center', flexWrap: 'wrap' }}>
            <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
              <input type="checkbox" style={{ accentColor: 'var(--color-accent)', width: '20px', height: '20px' }} />
              Toggle Checkbox
            </label>
            
            <select style={{
              background: 'var(--color-raised)',
              border: '1px solid var(--color-hairline)',
              color: 'var(--color-text)',
              padding: '12px 16px',
              borderRadius: 'var(--radius-small)',
              fontSize: 'var(--text-body)',
              outline: 'none'
            }}>
              <option>Select Option 1</option>
              <option>Select Option 2</option>
            </select>

            <span style={{
              background: 'var(--color-success)',
              color: 'white',
              padding: '4px 12px',
              borderRadius: '16px',
              fontSize: 'var(--text-small)',
              fontWeight: 600
            }}>Active Pill</span>
            
            <span style={{
              background: 'var(--color-muted)',
              color: 'white',
              padding: '4px 12px',
              borderRadius: '16px',
              fontSize: 'var(--text-small)',
              fontWeight: 600
            }}>Draft Pill</span>
          </div>
        </section>
      </div>
    </div>
  );
}
