const { spawnSync } = require('child_process');

const secrets = {
  PAYSTACK_SECRET_KEY: 'sk_test_27ff50a2d4f721edc6d8a74fab2d5cc38156c8f3',
  PAYSTACK_STANDARD_PLAN: 'PLN_qisv1frx0iqidqg',
  PAYSTACK_STUDENT_PLAN: 'PLN_n3vk3z20owktthk'
};

for (const [key, value] of Object.entries(secrets)) {
  console.log(`Setting ${key}...`);
  spawnSync('npx.cmd', ['wrangler', 'secret', 'put', key], {
    input: value,
    stdio: ['pipe', 'inherit', 'inherit']
  });
}
console.log("All secrets set successfully.");
