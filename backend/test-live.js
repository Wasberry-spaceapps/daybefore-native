fetch('https://daybefore-backend.officialmutairu.workers.dev/api/paystack/checkout', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ plan: 'standard' })
}).then(res => res.json()).then(console.log).catch(console.error);
