fetch('https://daybefore-backend.officialmutairu.workers.dev/api/webhooks/paddle', {
  method: 'POST',
  headers: {
    'paddle-signature': 'ts=1700000000;h1=fake',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ data: 'fake' })
})
.then(async r => {
  console.log('Status:', r.status);
  console.log('Body:', await r.text());
})
.catch(console.error);
