import { useState, useEffect, useRef } from 'react';
import { initializePaddle, Paddle } from '@paddle/paddle-js';

const API_URL = (import.meta as any).env.VITE_API_URL || 'https://daybefore-backend.officialmutairu.workers.dev/api';

export default function Pricing() {
  const paddleRef = useRef<Paddle>();
  const [pricing, setPricing] = useState({ standard: 'Loading...', student: 'Loading...' });
  const [region, setRegion] = useState<'rest_of_world' | 'nigeria' | 'loading'>('loading');
  
  useEffect(() => {
    // Geo-Routing Logic
    fetch('https://get.geojs.io/v1/ip/country.json')
      .then(res => res.json())
      .then(data => {
        if (data.country === 'NG') setRegion('nigeria');
        else setRegion('rest_of_world');
      })
      .catch(() => setRegion('rest_of_world'));
  }, []);

  useEffect(() => {
    if (region !== 'rest_of_world') return;

    const initPaddle = async () => {
      const env = (import.meta as any).env.VITE_PADDLE_ENVIRONMENT;
      const token = (import.meta as any).env.VITE_PADDLE_CLIENT_TOKEN;
      const standardId = (import.meta as any).env.VITE_PADDLE_STANDARD_PRICE_ID;
      const studentId = (import.meta as any).env.VITE_PADDLE_STUDENT_PRICE_ID;
      
      if (!env || !token || !standardId || !studentId) return;

      try {
        const paddleInstance = await initializePaddle({ environment: env as any, token });
        if (paddleInstance) {
          paddleRef.current = paddleInstance;
          const preview = await paddleInstance.PricePreview({
            items: [{ priceId: standardId, quantity: 1 }, { priceId: studentId, quantity: 1 }]
          });
          const stdItem = preview.data.details.lineItems.find((i: any) => i.price.id === standardId);
          const stuItem = preview.data.details.lineItems.find((i: any) => i.price.id === studentId);
          setPricing({
            standard: stdItem ? stdItem.formattedTotals.total : 'N/A',
            student: stuItem ? stuItem.formattedTotals.total : 'N/A'
          });
        }
      } catch (err) {
        console.error("Failed to init Paddle", err);
      }
    };
    initPaddle();
  }, [region]);

  const openPaddleCheckout = (priceId: string) => {
    const token = localStorage.getItem('daybefore_token');
    if (!token) {
      alert('Please create an account first.');
      window.location.hash = '#auth';
      return;
    }
    if (!paddleRef.current) return alert("Loading checkout, please wait.");
    paddleRef.current.Checkout.open({
      settings: { displayMode: 'overlay', variant: 'one-page' },
      items: [{ priceId, quantity: 1 }],
      customData: { accountId: token }
    });
  };

  const handlePaystackCheckout = async (plan: 'standard' | 'student') => {
    const token = localStorage.getItem('daybefore_token');
    if (!token) {
      alert('Please create an account first.');
      window.location.hash = '#auth';
      return;
    }
    try {
      const res = await fetch(`${API_URL}/paystack/checkout`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ plan, accountId: token })
      });
      const data = await res.json();
      if (data.url) {
        window.location.href = data.url;
      } else {
        alert('Failed to initialize Paystack checkout.');
      }
    } catch (e) {
      alert('Error initiating checkout.');
    }
  };

  return (
    <div className="page-container">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '64px' }}>
        <h1 style={{ fontSize: '2rem', fontWeight: 500, letterSpacing: '0.02em', cursor: 'pointer' }} onClick={() => window.location.hash = ''}>
          Day Before
        </h1>
        <button onClick={() => window.location.hash = ''} style={{ color: 'var(--text-secondary)' }}>Back to Home</button>
      </div>
      
      <div style={{ marginBottom: '64px' }}>
        <h2 style={{ fontSize: '1.2rem', marginBottom: '24px', fontWeight: 500 }}>Select a Plan</h2>
        
        {region === 'loading' ? (
          <div style={{ color: 'var(--text-secondary)' }}>Loading localized pricing...</div>
        ) : (
          <div style={{ display: 'grid', gap: '32px' }}>
            <div>
              <div style={{ fontWeight: 500 }}>Free</div>
              <div style={{ color: 'var(--text-secondary)' }}>Full local app, unlimited entries, all three areas, the game. No account required, nothing ever leaves the device.</div>
              <button 
                onClick={() => window.location.hash = '#app'}
                style={{ marginTop: '12px', padding: '8px 16px', border: '1px solid var(--text-primary)', borderRadius: '4px', cursor: 'pointer', background: 'transparent', color: 'var(--text-primary)' }}>
                Open Free App
              </button>
            </div>
            
            {region === 'nigeria' ? (
              <>
                {/* Paystack NGN Pricing */}
                <div>
                  <div style={{ fontWeight: 500 }}>₦1,400 / month</div>
                  <div style={{ color: 'var(--text-secondary)' }}>Adds encrypted cloud sync across devices. (Billed via Paystack)</div>
                  <button 
                    onClick={() => handlePaystackCheckout('standard')}
                    style={{ marginTop: '12px', padding: '8px 16px', border: '1px solid var(--accent)', color: 'var(--accent)', background: 'transparent', borderRadius: '4px', cursor: 'pointer' }}>
                    Subscribe (Standard NGN)
                  </button>
                </div>
                <div>
                  <div style={{ fontWeight: 500 }}>₦800 / month (Student)</div>
                  <div style={{ color: 'var(--text-secondary)' }}>Discounted sync tier. Requires school email or supporting document for manual verification.</div>
                  <button 
                    onClick={() => handlePaystackCheckout('student')}
                    style={{ marginTop: '12px', padding: '8px 16px', border: '1px solid var(--divider)', background: 'transparent', color: 'var(--text-secondary)', borderRadius: '4px', cursor: 'pointer' }}>
                    Subscribe (Student NGN)
                  </button>
                </div>
              </>
            ) : (
              <>
                {/* Paddle Global Pricing */}
                <div>
                  <div style={{ fontWeight: 500 }}>{pricing.standard} / month</div>
                  <div style={{ color: 'var(--text-secondary)' }}>Adds encrypted cloud sync across devices.</div>
                  <button 
                    onClick={() => openPaddleCheckout((import.meta as any).env.VITE_PADDLE_STANDARD_PRICE_ID)}
                    style={{ marginTop: '12px', padding: '8px 16px', border: '1px solid var(--accent)', color: 'var(--accent)', background: 'transparent', borderRadius: '4px', cursor: 'pointer' }}>
                    Subscribe (Standard)
                  </button>
                </div>
                <div>
                  <div style={{ fontWeight: 500 }}>{pricing.student} / month (Student)</div>
                  <div style={{ color: 'var(--text-secondary)' }}>Discounted sync tier. Requires school email or supporting document for manual verification.</div>
                  <button 
                    onClick={() => openPaddleCheckout((import.meta as any).env.VITE_PADDLE_STUDENT_PRICE_ID)}
                    style={{ marginTop: '12px', padding: '8px 16px', border: '1px solid var(--divider)', background: 'transparent', color: 'var(--text-secondary)', borderRadius: '4px', cursor: 'pointer' }}>
                    Subscribe (Student)
                  </button>
                </div>
              </>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
