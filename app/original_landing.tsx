export default function Landing() {
  return (
    <div className="page-container">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '64px' }}>
        <h1 style={{ fontSize: '2rem', fontWeight: 500, letterSpacing: '0.02em' }}>Day Before</h1>
        <button onClick={() => window.location.hash = '#pricing'} style={{ color: 'var(--text-secondary)' }}>
          Pricing
        </button>
      </div>
      
      <div style={{ marginBottom: '64px', marginTop: '15vh' }}>
        <p style={{ fontSize: '2rem', color: 'var(--text-primary)', whiteSpace: 'pre-wrap', lineHeight: '1.4', marginBottom: '16px' }}>
          {"A journal.\nA journal to get better."}
        </p>
        <p style={{ color: 'var(--text-secondary)', fontWeight: 500, fontSize: '1.1rem', marginBottom: '8px' }}>
          Your issues and insights, kept safe and with you everywhere
        </p>
        <p style={{ color: 'var(--text-secondary)', fontWeight: 500, fontSize: '1.1rem' }}>
          Native mobile and desktop apps are available now.
        </p>
      </div>

      <div style={{ marginBottom: '64px', display: 'flex', flexDirection: 'column', gap: '32px' }}>
        <div>
          <h2 style={{ fontSize: '1.2rem', fontWeight: 500, marginBottom: '8px' }}>Journal</h2>
          <p style={{ color: 'var(--text-secondary)' }}>Put the day down, and leave it there.</p>
        </div>
        <div>
          <h2 style={{ fontSize: '1.2rem', fontWeight: 500, marginBottom: '8px' }}>Core Points</h2>
          <p style={{ color: 'var(--text-secondary)' }}>The few important standards we hold ourselves up against.</p>
        </div>
        <div>
          <h2 style={{ fontSize: '1.2rem', fontWeight: 500, marginBottom: '8px' }}>Issues</h2>
          <p style={{ color: 'var(--text-secondary)' }}>The areas we have to work on repeatedly, to try to improve on.</p>
        </div>
      </div>

      <div style={{ marginBottom: '64px', display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
        <button 
          onClick={() => window.location.hash = '#app'}
          style={{ padding: '12px 24px', border: '1px solid var(--text-primary)', borderRadius: '4px', cursor: 'pointer', background: 'transparent', color: 'var(--text-primary)', fontSize: '1.1rem' }}>
          Open Web App
        </button>
        <button 
          onClick={() => window.open('https://github.com/Wasberry-spaceapps/daybefore-native/releases/latest/download/DayBefore-Setup.exe', '_blank')}
          style={{ padding: '12px 24px', border: '1px solid var(--text-secondary)', borderRadius: '4px', cursor: 'pointer', background: 'transparent', color: 'var(--text-secondary)', fontSize: '1.1rem' }}>
          Download for Windows
        </button>
        <button 
          onClick={() => window.open('https://github.com/Wasberry-spaceapps/daybefore-native/releases/latest/download/DayBefore-macOS.dmg', '_blank')}
          style={{ padding: '12px 24px', border: '1px solid var(--text-secondary)', borderRadius: '4px', cursor: 'pointer', background: 'transparent', color: 'var(--text-secondary)', fontSize: '1.1rem' }}>
          Download for Mac
        </button>
        <button 
          onClick={() => window.open('https://github.com/Wasberry-spaceapps/daybefore-native/releases/latest/download/DayBefore-android.apk', '_blank')}
          style={{ padding: '12px 24px', border: '1px solid var(--text-secondary)', borderRadius: '4px', cursor: 'pointer', background: 'transparent', color: 'var(--text-secondary)', fontSize: '1.1rem' }}>
          Download for Android
        </button>
      </div>

      <div className="footer-links">
        <a href="#legal" style={{ color: 'var(--text-secondary)', textDecoration: 'none' }}>Terms of Service</a>
        <a href="#legal" style={{ color: 'var(--text-secondary)', textDecoration: 'none' }}>Privacy Policy</a>
        <a href="#legal" style={{ color: 'var(--text-secondary)', textDecoration: 'none' }}>Refund Policy</a>
        <a href="mailto:mutairuwasiu929@gmail.com" style={{ color: 'var(--text-secondary)', textDecoration: 'none' }}>Contact Us</a>
      </div>
    </div>
  );
}
