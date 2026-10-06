const API_KEY = 'pdl_sdbx_apikey_01m3hky3a9mh97r9tbexh0zkj1_Sf4FyZ2sdz1KEmrB40f2Aw_A8S';
const crypto = require('crypto');

async function debug() {
  const r = await fetch('https://api.paddle.com/notifications', {
    headers: { 'Authorization': `Bearer ${API_KEY}` }
  });
  const data = await r.json();
  const latest = data.data[0];
  
  const payloadRes = await fetch(`https://api.paddle.com/notifications/${latest.id}`, {
    headers: { 'Authorization': `Bearer ${API_KEY}` }
  });
  const payloadData = await payloadRes.json();
  
  const rawBody = JSON.stringify(payloadData.data.payload);
  const secret = 'pdl_ntfset_01m3hr9n916kybg8jdy01xjhgv_8zebxI/kyoe3Ybo4MLmeR3/yPen49awK';
  
  const ts = Math.floor(Date.now() / 1000);
  const h1 = crypto.createHmac('sha256', secret).update(`${ts}:${rawBody}`).digest('hex');
  const signature = `ts=${ts};h1=${h1}`;
  
  console.log("Testing worker with actual payload...");
  const workerRes = await fetch('https://daybefore-backend.officialmutairu.workers.dev/api/webhooks/paddle', {
    method: 'POST',
    headers: {
      'paddle-signature': signature,
      'Content-Type': 'application/json'
    },
    body: rawBody
  });
  
  console.log("Status:", workerRes.status);
  console.log("Response:", await workerRes.text());
}
debug();
