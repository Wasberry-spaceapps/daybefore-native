import { Paddle, Environment } from '@paddle/paddle-node-sdk';

const API_KEY = 'pdl_live_apikey_01m3jhwkqzk7k92rs1pvrt2ka1_70gqfnWjKJEa3Cb9RqzSNF_ANj';
const paddle = new Paddle(API_KEY, { environment: Environment.production });

async function createDiscount() {
  try {
    const discount = await paddle.discounts.create({
      description: "Live Test 100% Off",
      type: "percentage",
      amount: "100",
      code: "LIVETEST100",
      enabledForCheckout: true,
      usageLimit: 5 // A few tries in case of typos
    });
    console.log("Successfully created discount!");
    console.log("Code:", discount.code);
    console.log("ID:", discount.id);
  } catch (error) {
    console.error("Failed to create discount:");
    console.error(error.message);
  }
}

createDiscount();
