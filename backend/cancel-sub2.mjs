import { Paddle, Environment } from '@paddle/paddle-node-sdk';

const API_KEY = 'pdl_live_apikey_01m3jhwkqzk7k92rs1pvrt2ka1_70gqfnWjKJEa3Cb9RqzSNF_ANj';
const paddle = new Paddle(API_KEY, { environment: Environment.production });

async function getAndCancelLatest() {
  try {
    const subs = paddle.subscriptions.list({ statuses: ['active', 'trialing'] });
    for await (const sub of subs) {
      console.log("Found active test subscription:", sub.id);
      const canceled = await paddle.subscriptions.cancel(sub.id, { effectiveFrom: 'immediately' });
      console.log("Subscription canceled successfully!", canceled.status);
      return; // Just cancel the first one we find
    }
    console.log("No active subscriptions found.");
  } catch (e) {
    console.error("Error:", e.message);
  }
}
getAndCancelLatest();
