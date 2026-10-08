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
        <p>By using Day Before, you agree to these terms. Day Before is provided as-is, without warranties. You are solely responsible for keeping your passphrase and recovery key safe. Because of end-to-end encryption, nobody — including us — can recover entries without these credentials. The service may be modified or discontinued at any time.</p>
      </section>

      <section style={{ marginBottom: '64px' }}>
        <h2 style={{ color: 'var(--text-primary)', marginBottom: '16px' }}>Privacy Policy</h2>
        <p>All journal entries, issues, and core points are encrypted on your device using AES-GCM-256 before they leave it. What the server stores is ciphertext it cannot read. Your email address is hashed for authentication — the plaintext is not stored server-side. The only metadata collected is the general region (continent) at registration, for anonymous internal metrics.</p>
        <p>We use Plausible Analytics — cookieless, privacy-first — to count anonymous visits. No personal identities are tracked.</p>
      </section>

      <section style={{ marginBottom: '64px' }}>
        <h2 style={{ color: 'var(--text-primary)', marginBottom: '16px' }}>Refund &amp; Cancellation Policy</h2>
        <p>You can cancel your subscription at any time through account settings or the "Manage Subscription" link in the original Paddle email receipt. Cancellation takes effect at the end of the current billing cycle. Your entries remain on the device, fully usable — only sync stops.</p>
        <p>If you are unsatisfied, a full refund is available within 14 days of the initial purchase. Contact support@daybefore.app.</p>
      </section>
    </div>
  );
}
