// @ts-nocheck
import React from 'react';

export default function Landing() {
  return (
    <div className="page-container" style={{
      maxWidth: '800px',
      margin: '0 auto',
      padding: '0 24px',
      color: 'var(--text-primary)',
      fontFamily: 'var(--font-display)',
      lineHeight: '1.6'
    }}>
      {/* Header */}
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', margin: '48px 0' }}>
        <h1 style={{ fontSize: '1.5rem', fontWeight: 'normal', margin: 0 }}>Day Before</h1>
        <nav style={{ display: 'flex', gap: '24px' }}>
          
          <a href="#pricing" style={{ color: 'var(--text-secondary)', textDecoration: 'none', fontFamily: 'var(--font-sans)', fontSize: '0.9rem', marginRight: '24px' }}>Pricing</a><a href="#app" style={{ color: 'var(--text-secondary)', textDecoration: 'none', fontFamily: 'var(--font-sans)', fontSize: '0.9rem' }}>Log in</a>
        </nav>
      </header>

      <main>
        {/* Hero */}
        <section style={{ margin: '120px 0 80px' }}>
          <h2 style={{ fontSize: '2.5rem', fontWeight: 'normal', margin: '0 0 24px 0', lineHeight: '1.3' }}>
            Write the day down, then notice what keeps coming back.
          </h2>
          <p style={{ fontSize: '1.2rem', color: 'var(--text-secondary)', margin: '0 0 48px 0', maxWidth: '650px' }}>
            A private journal, with a quiet place for the few things you keep getting wrong, where you can return to them, reconsider what you believe about them, and read back, in your own words, whether you are changing.
          </p>
          <div style={{ display: 'flex', gap: '16px', alignItems: 'center', flexWrap: 'wrap' }}>
            <button 
              onClick={() => window.location.hash = '#app'}
              style={{
                background: 'var(--text-primary)',
                color: 'var(--color-ground, var(--bg-color))',
                border: 'none',
                padding: '12px 24px',
                borderRadius: '4px',
                fontFamily: 'var(--font-sans)',
                fontSize: '1rem',
                cursor: 'pointer'
              }}>
              Open the free app
            </button>
            <a href="#how-it-works" style={{
              color: 'var(--text-primary)',
              textDecoration: 'none',
              fontFamily: 'var(--font-sans)',
              fontSize: '1rem',
              padding: '12px 24px',
              border: '1px solid var(--hairline)',
              borderRadius: '4px'
            }}>
              How it works
            </a>
          </div>
          <p style={{ fontFamily: 'var(--font-sans)', fontSize: '0.85rem', color: 'var(--text-muted)', marginTop: '24px' }}>
            It is free and stays on your device, encrypted, and sync is there only if you want it.
          </p>
        </section>



        {/* Two Things In One Place */}
        <section style={{ margin: '120px 0' }}>
          <h3 style={{ fontFamily: 'var(--font-sans)', fontSize: '0.85rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em', margin: '0 0 48px 0' }}>
            Two things in one place
          </h3>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '48px' }}>
            <div>
              <h4 style={{ fontSize: '1.75rem', fontWeight: 500, margin: '0 0 12px 0' }}>Journal</h4>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: 0, lineHeight: '1.5' }}>
                Most days deserve a page, even a short one. Write down what happened and what you made of it, and then leave it alone until you want it again.
              </p>
            </div>
            
            <div>
              <h4 style={{ fontSize: '1.75rem', fontWeight: 500, margin: '0 0 12px 0' }}>Issues</h4>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: 0, lineHeight: '1.5' }}>
                Some things in us repeat: a short temper, a flash of envy, a small selfishness we only notice afterwards. Here you can give each one a name and write down what you think causes it and what you intend to try. When it returns, you come back, add what happened, and revise the theory if it no longer holds. The earlier versions stay where they were, dated, so you can watch your thinking change.
              </p>
            </div>
            
            <div>
              <h4 style={{ fontSize: '1.75rem', fontWeight: 500, margin: '0 0 12px 0' }}>Core Points</h4>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: 0, lineHeight: '1.5' }}>
                The few standards you hold yourself against. Short enough to remember, kept where you will see them.
              </p>
            </div>
          </div>
        </section>

        {/* How It Works */}
        <section id="how-it-works" style={{ margin: '120px 0', padding: '48px', background: 'var(--ground-raised)', borderRadius: '8px', border: '1px solid var(--hairline)' }}>
          <h3 style={{ fontFamily: 'var(--font-sans)', fontSize: '0.85rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em', margin: '0 0 32px 0' }}>
            How it works
          </h3>
          
          <ol style={{ padding: 0, margin: 0, listStylePosition: 'inside', color: 'var(--text-secondary)', display: 'flex', flexDirection: 'column', gap: '24px', fontSize: '1.1rem' }}>
            <li style={{ margin: 0 }}><strong style={{ color: 'var(--text-primary)', fontWeight: 500 }}>Name it.</strong> A single line is enough to begin with.</li>
            <li style={{ margin: 0 }}><strong style={{ color: 'var(--text-primary)', fontWeight: 500 }}>Write your theory.</strong> why you think it happens, what you believe about it, and what you will try next time.</li>
            <li style={{ margin: 0 }}><strong style={{ color: 'var(--text-primary)', fontWeight: 500 }}>Return.</strong> when it happens again, record what happened, and change the theory once it stops being true.</li>
          </ol>
          
          <p style={{ color: 'var(--text-secondary)', marginTop: '32px', fontStyle: 'italic' }}>
            After some months, read it through from the beginning. What you find there is better evidence than memory.
          </p>
        </section>

        {/* Security & Platforms */}
        <section style={{ margin: '120px 0' }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '48px' }}>
            <div>
              <h3 style={{ fontFamily: 'var(--font-sans)', fontSize: '0.85rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em', margin: '0 0 24px 0' }}>
                PRIVATE, AND YOURS TO KEEP
              </h3>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: 0, lineHeight: '1.5' }}>
                Everything you write is encrypted on your own device before it goes anywhere, so what we store is text we cannot read. The other side of that is that we cannot recover it for you either, which is why you receive a recovery key when you sign up. Please keep it somewhere safe.<br/><br/>Because a journal is often read over a shoulder, Day Before asks for your password again whenever you leave and come back, unless you tell it not to.<br/><br/>Your entries remain yours. You can export all of them at any time, as Markdown or as a PDF, and take them wherever you like.
              </p>
            </div>
            
            <div>
              <h3 style={{ fontFamily: 'var(--font-sans)', fontSize: '0.85rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em', margin: '0 0 24px 0' }}>
                On every device you write on
              </h3>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: '0 0 24px 0', lineHeight: '1.5' }}>
                Day Before runs in the browser and as an app for Android, Windows and Mac, with iPhone to follow. It works offline, and you can turn on sync whenever you would like your entries in more than one place.
              </p>
              <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
                <a href="https://github.com/Wasberry-spaceapps/daybefore-native/releases/latest/download/DayBefore-Setup.exe" style={{ fontFamily: 'var(--font-sans)', fontSize: '0.9rem', color: 'var(--text-primary)', textDecoration: 'underline' }}>Windows</a>
                <a href="https://github.com/Wasberry-spaceapps/daybefore-native/releases/latest/download/DayBefore-macOS.dmg" style={{ fontFamily: 'var(--font-sans)', fontSize: '0.9rem', color: 'var(--text-primary)', textDecoration: 'underline' }}>Mac</a>
                <a href="https://github.com/Wasberry-spaceapps/daybefore-native/releases/latest/download/DayBefore-android.apk" style={{ fontFamily: 'var(--font-sans)', fontSize: '0.9rem', color: 'var(--text-primary)', textDecoration: 'underline' }}>Android</a>
              </div>
            </div>
          </div>
        </section>

        {/* FAQ */}
        <section style={{ margin: '120px 0' }}>
          <h3 style={{ fontFamily: 'var(--font-sans)', fontSize: '0.85rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em', margin: '0 0 48px 0' }}>
            FAQ
          </h3>
          <dl style={{ display: 'flex', flexDirection: 'column', gap: '32px', margin: 0 }}>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>Who can read my entries?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>Only you.</dd>
            </div>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>What if I forget my password?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>Reset it by email, then use your recovery key to open your older entries. Without the key, older entries stay locked and you can start fresh.</dd>
            </div>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>Does it work offline?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>Yes.</dd>
            </div>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>What happens if I stop paying?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>You keep everything. Only syncing stops.</dd>
            </div>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>How do students get the price?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>Confirm a school email, or send proof of enrolment.</dd>
            </div>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>Can I leave?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>Export everything, any time.</dd>
            </div>
          </dl>
        </section>

      </main>

      <footer style={{ borderTop: '1px solid var(--hairline)', padding: '48px 0', display: 'flex', gap: '24px', flexWrap: 'wrap', fontFamily: 'var(--font-sans)', fontSize: '0.85rem' }}>
        <a href="#terms" style={{ color: 'var(--text-muted)', textDecoration: 'none' }}>Terms</a>
        <a href="#privacy" style={{ color: 'var(--text-muted)', textDecoration: 'none' }}>Privacy</a>
        <a href="#refunds" style={{ color: 'var(--text-muted)', textDecoration: 'none' }}>Refunds</a>
        <a href="mailto:mutairuwasiu929@gmail.com" style={{ color: 'var(--text-muted)', textDecoration: 'none' }}>Contact</a>
      </footer>
    </div>
  );
}
