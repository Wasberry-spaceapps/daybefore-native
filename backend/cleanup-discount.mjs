import { Paddle, Environment } from '@paddle/paddle-node-sdk';

const API_KEY = 'pdl_live_apikey_01m3jhwkqzk7k92rs1pvrt2ka1_70gqfnWjKJEa3Cb9RqzSNF_ANj';
const paddle = new Paddle(API_KEY, { environment: Environment.production });

async function cleanup() {
  try {
    // We update the discount to disable it, rather than archive (v1 API often uses status updates)
    const discount = await paddle.discounts.update('dsc_01m3jrrcc4dke003p5ew818r22', {
      status: 'archived' // or restrict it
    });
    console.log("Discount archived successfully!");
  } catch (error) {
    console.error("Failed to archive discount:", error.message);
  }
}

cleanup();
