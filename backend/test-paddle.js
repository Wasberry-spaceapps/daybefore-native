const API_KEY = 'pdl_sdbx_apikey_01m3hky3a9mh97r9tbexh0zkj1_Sf4FyZ2sdz1KEmrB40f2Aw_A8S';
fetch('https://api.paddle.com/notifications?status=failed', {
  headers: { 'Authorization': `Bearer ${API_KEY}` }
})
.then(r => r.json())
.then(data => {
  const last5 = data.data.slice(0, 5);
  console.log(JSON.stringify(last5.map(n => ({
    type: n.type,
    status: n.status,
    http_code: n.last_attempt?.response_status_code,
    error: n.last_attempt?.error
  })), null, 2));
})
.catch(console.error);
