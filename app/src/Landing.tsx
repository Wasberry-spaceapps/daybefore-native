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
            A journal, with issues.
          </h2>
          <p style={{ fontSize: '1.2rem', color: 'var(--text-secondary)', margin: '0 0 48px 0', maxWidth: '650px' }}>
            We write the day down. And then there are the things that keep coming back — the patterns we notice in ourselves, the deficiencies we would rather not look at but know we must. We open them up, return to them, and over days and weeks work out what we actually think. And then we come back — to remember what we decided, to train it into ourselves, and to refine it further when we can.
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
              Open the app
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
            Free. Encrypted on your device. Sync only if you want it.
          </p>
        </section>

        {Object.keys(import.meta.glob('/public/media/introducing.mp4', { eager: true })).length > 0 && (
          <section style={{ margin: '80px 0', aspectRatio: '16/9', background: 'var(--hairline)', borderRadius: '8px', overflow: 'hidden' }}>
            <video controls preload="metadata" playsInline poster="/media/introducing-poster.jpg" style={{ width: '100%', height: '100%', objectFit: 'cover' }}>
              <source src="/media/introducing.mp4" type="video/mp4" />
            </video>
          </section>
        )}

        {/* Two Things In One Place */}
        <section style={{ margin: '120px 0' }}>
          <h3 style={{ fontFamily: 'var(--font-sans)', fontSize: '0.85rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em', margin: '0 0 48px 0' }}>
            What it is
          </h3>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '48px' }}>
            <div>
              <h4 style={{ fontSize: '1.75rem', fontWeight: 500, margin: '0 0 12px 0' }}>Journal</h4>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: 0, lineHeight: '1.5' }}>
                Most days deserve a page, even a short one. We write down what happened and what we made of it, and then leave it alone until we want it again.
              </p>
            </div>

            <div>
              <h4 style={{ fontSize: '1.75rem', fontWeight: 500, margin: '0 0 12px 0' }}>Issues</h4>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: 0, lineHeight: '1.5' }}>
                Some things in us repeat. A short temper. A tendency to take all the credit instead of sharing it. An inability to sit still when the world around us is loud. We give each one a name, and we write what we honestly think is behind it — not the comfortable explanation, the real one. When it surfaces again, we return and add to what we wrote. Often the problem is deeper than we first named it — what looked like an inability to share was really a selfishness we had not fully confronted; the restlessness in loud places was not about the noise but about the stillness we had not yet built in ourselves.
              </p>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: '16px 0 0 0', lineHeight: '1.5' }}>
                Over days and weeks, coming back to the same entry, the understanding gets closer to something true. And even once that area of our life settles, new depth opens up — if we built stillness, we now want to hold it even in the moment right after something provokes us. The entries stay, dated. We come back to remember what we decided, to train it into ourselves, and to push it further when we can.
              </p>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: '16px 0 0 0', lineHeight: '1.5', fontStyle: 'italic' }}>
                "We are what we repeatedly do." — Will Durant, summarizing Aristotle
              </p>
            </div>

            <div>
              <h4 style={{ fontSize: '1.75rem', fontWeight: 500, margin: '0 0 12px 0' }}>Core Points</h4>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: 0, lineHeight: '1.5' }}>
                The few standards we hold ourselves against. Short enough to remember, kept where we will see them.
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
            <li style={{ margin: 0 }}><strong style={{ color: 'var(--text-primary)', fontWeight: 500 }}>Name it.</strong> We recognize something in ourselves that needs work, and we open it up. A single honest line is enough.</li>
            <li style={{ margin: 0 }}><strong style={{ color: 'var(--text-primary)', fontWeight: 500 }}>Write what we think.</strong> What is behind it. What we believe right now. What we will try the next time it shows up.</li>
            <li style={{ margin: 0 }}><strong style={{ color: 'var(--text-primary)', fontWeight: 500 }}>Return.</strong> Over days and weeks, we come back. We add to what is there, work through to what we actually think, and arrive at what feels true. The entry stays — a place to return to, to remember what we decided, to hold ourselves to it, and to push it further when we can.</li>
          </ol>

          <p style={{ color: 'var(--text-secondary)', marginTop: '32px', fontStyle: 'italic' }}>
            After some months, read it from the beginning. The work we did is there. So is what we have left to do.
          </p>
        </section>

        {/* Security & Platforms */}
        <section style={{ margin: '120px 0' }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '48px' }}>
            <div>
              <h3 style={{ fontFamily: 'var(--font-sans)', fontSize: '0.85rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em', margin: '0 0 24px 0' }}>
                Private, and yours to keep
              </h3>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: 0, lineHeight: '1.5' }}>
                Everything you write is encrypted on your device before it goes anywhere. What the server stores is text it cannot read. The other side of that is real: nobody can recover it for you either — which is why you receive a recovery key when you sign up. Keep it somewhere safe.<br/><br/>Because a journal is often read over a shoulder, Day Before asks for your password again whenever you leave and come back.<br/><br/>Your entries remain yours. You can export all of them at any time, as Markdown or as a PDF, and take them wherever you like.
              </p>
            </div>

            <div>
              <h3 style={{ fontFamily: 'var(--font-sans)', fontSize: '0.85rem', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '0.05em', margin: '0 0 24px 0' }}>
                On every device we write on
              </h3>
              <p style={{ fontSize: '1.1rem', color: 'var(--text-secondary)', margin: '0 0 24px 0', lineHeight: '1.5' }}>
                Day Before runs in the browser and as an app for Android, Windows, and Mac, with iPhone to follow. It works offline. Sync is there only when you want your entries in more than one place.
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
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>Only you. End-to-end encrypted, on your device, before anything leaves it.</dd>
            </div>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>What if I forget my password?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>That is what the recovery key is for. Without it, the encrypted entries cannot be opened — not by you, not by anyone. This is the honest trade-off of real encryption.</dd>
            </div>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>Why call them "issues"?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>Because that is what they are. We are not tracking habits or setting goals — we are confronting the specific things in ourselves that we keep getting wrong. The word is plain and honest, which felt right for something that asks us to be the same.</dd>
            </div>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>What happens if I stop paying?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>Nothing. Only syncing across devices stops. The journal and all your entries remain on the device, fully usable.</dd>
            </div>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>Can I take my entries elsewhere?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>Export everything, any time. Your entries are yours.</dd>
            </div>
            <div>
              <dt style={{ color: 'var(--text-primary)', marginBottom: '8px' }}>Are there streaks?</dt>
              <dd style={{ color: 'var(--text-secondary)', margin: 0 }}>No. And there will not be. A day we do not write is simply a day we did not write. The point is to come back when we have something to say, not to maintain a number.</dd>
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
