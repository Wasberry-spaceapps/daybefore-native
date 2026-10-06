# Day Before - Project Handoff Document

Welcome to the Day Before project! This document contains everything you need to take absolute control of the site, manage the codebase, handle deployments, and manage the payment processors.

## 1. Tech Stack Overview
- **Frontend**: React + TypeScript + Vite, deployed on **Cloudflare Pages**.
- **Backend / API**: Hono (TypeScript), deployed on **Cloudflare Workers**.
- **Database**: Cloudflare D1 (Serverless SQLite).
- **International Payments**: Paddle Billing.
- **Nigerian Payments**: Paystack.
- **Analytics**: Plausible Analytics.

## 2. Directory Structure
The codebase is located in the folder this README is inside (`daybefore`):
- `/app/`: The frontend React codebase.
- `/backend/`: The backend Cloudflare Worker and database schemas.

## 3. The Required Accounts
To take full ownership, the previous owner needs to transfer the following accounts to you, or provide you with the login credentials:

1. **Cloudflare**: Hosts the frontend, backend API, and the D1 Database. This is the most important account.
2. **Paddle**: Handles all international subscription billing.
3. **Paystack**: Handles local Nigerian billing.
4. **Plausible Analytics**: Tracks website visitors.
5. **Domain Registrar**: Wherever `daybefore.app` was registered.

## 4. Master List of Environment Variables & API Keys
Here are the live production keys currently hardcoded or used in the environment variables:

### Frontend (\`/app/.env\`)
- \`VITE_API_URL\`: \`https://daybefore-backend.officialmutairu.workers.dev/api\`
- \`VITE_PADDLE_ENVIRONMENT\`: \`production\`
- \`VITE_PADDLE_CLIENT_TOKEN\`: \`live_d1700aa556bd70ff074551edd80\`
- \`VITE_PADDLE_STANDARD_PRICE_ID\`: \`pri_01m3jhz3vtbrh9ecdfkcmfynp6\`
- \`VITE_PADDLE_STUDENT_PRICE_ID\`: \`pri_01m3jhz450jtne1vmkge9b94pr\`

### Backend (\`/backend/src/index.ts\`)
- \`PADDLE_API_KEY\`: \`pdl_live_apikey_01m3jhwkqzk7k92rs1pvrt2ka1_70gqfnWjKJEa3Cb9RqzSNF_ANj\`
- \`PADDLE_WEBHOOK_SECRET\`: \`pdl_ntfset_01m3jk2w0qxjn12xjhjha6215e_MesyQQiR2r80t3G+MK3P1soFYROiXppG\`
- \`PAYSTACK_SECRET_KEY\`: \`sk_live_39277e4ba54bcc3a9f1f08ecb79b333a997ac95a\`
- \`PAYSTACK_STANDARD_PLAN\`: \`PLN_imvt06adlo6rdk0\`
- \`PAYSTACK_STUDENT_PLAN\`: \`PLN_0iuejc9p3wkfsk9\`

## 5. How to Run Locally

### Run the Frontend
1. Open terminal and navigate to \`app/\`
2. Run \`npm install\`
3. Run \`npm run dev\`
4. The local site will start at \`http://localhost:5173\`

### Run the Backend
1. Open terminal and navigate to \`backend/\`
2. Run \`npm install\`
3. Run \`npm run dev\`
4. The API will start at \`http://localhost:8787\`

## 6. How to Deploy to Production

Both the frontend and backend are hosted on Cloudflare. You will need to install Wrangler (\`npm install -g wrangler\`) and log in using \`npx wrangler login\`.

### Deploy Frontend
\`\`\`bash
cd app
npm run build
npx wrangler pages deploy dist --project-name daybefore-app
\`\`\`

### Deploy Backend
\`\`\`bash
cd backend
npx wrangler deploy
\`\`\`

## 7. How to View the Live Database
The database is hosted on Cloudflare D1 (named \`daybefore_db\`).
To run a query against the live production database, use:
\`\`\`bash
npx wrangler d1 execute daybefore_db --remote --command="SELECT * FROM accounts"
\`\`\`

## 8. Paddle Onboarding Completion
Currently, the Paddle dashboard shows "03 Test and go live (In progress)". Because we tested the integration programmatically and verified the webhooks in the actual database, the integration is 100% complete and working. 
To clear that dashboard notification, simply log into Paddle, click into **Test and go live**, and there should be a button to **Mark as done** or **Complete**. Since your webhooks, prices, and default checkout URL are already completely hooked up and verified working, you can safely dismiss this onboarding banner.
