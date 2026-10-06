export default function Legal() {
  return (
    <div style={{ padding: '64px', maxWidth: '800px', margin: '0 auto', lineHeight: '1.6', color: 'var(--text-secondary)' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '64px' }}>
        <h1 style={{ fontSize: '2rem', fontWeight: 500, letterSpacing: '0.02em', color: 'var(--text-primary)', cursor: 'pointer' }} onClick={() => window.location.hash = ''}>
          Day Before
        </h1>
        <button onClick={() => window.location.hash = ''} style={{ background: 'transparent', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer' }}>Back to Home</button>
      </div>

      <section style={{ marginBottom: '64px' }}>
        <h2 style={{ color: 'var(--text-primary)', marginBottom: '16px' }}>Terms of Service</h2>
        <p>Last updated: {new Date().toLocaleDateString()}</p>
        <p>By using Day Before, you agree to these terms. Day Before is provided "as is" without warranties. You are solely responsible for keeping your passphrase secure; because of our end-to-end encryption, we cannot recover your data if you lose your passphrase. We reserve the right to modify or terminate the service at any time.</p>
      </section>

      <section style={{ marginBottom: '64px' }}>
        <h2 style={{ color: 'var(--text-primary)', marginBottom: '16px' }}>Privacy Policy</h2>
        <p>We believe in absolute data privacy. All journal entries and core points are end-to-end encrypted on your device using AES-GCM 256. Our servers only store encrypted blobs and can never read your content. We collect your email address for account authentication and billing purposes only.</p>
        <p>We use Plausible Analytics, a cookieless, privacy-first tool, to count anonymous visits and which areas get used, without tracking personal identities.</p>
      </section>

      <section style={{ marginBottom: '64px' }}>
        <h2 style={{ color: 'var(--text-primary)', marginBottom: '16px' }}>Refund & Cancellation Policy</h2>
        <p>You can cancel your subscription at any time through your account settings or by clicking the 'Manage Subscription' link in your original Paddle email receipt. Cancellations take effect at the end of your current billing cycle.</p>
        <p>If you are unsatisfied with the service, we offer a full refund within 14 days of your initial purchase. Contact support@daybefore.app to request a refund.</p>
      </section>
    </div>
  );
}
