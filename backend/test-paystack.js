const secret = 'sk_test_27ff50a2d4f721edc6d8a74fab2d5cc38156c8f3';
const plan = 'PLN_qisv1frx0iqidqg';

fetch('https://api.paystack.co/transaction/initialize', {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${secret}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email: 'user@daybefore.app',
    plan: plan,
    channels: ['card', 'bank']
  })
}).then(res => res.json()).then(console.log).catch(console.error);
