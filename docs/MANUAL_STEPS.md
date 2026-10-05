# Manual Steps

*Any blockers requiring manual intervention (dashboard-only settings, missing credentials) will be logged here with a one-line fix instruction.*

1. **Paystack Keys Missing**: You need to add Paystack test keys to the worker environments.
   *Fix:* `wrangler secret put PAYSTACK_SECRET_KEY` and add to `.dev.vars` locally.
2. **Email Provider Missing**: You need to add an email provider key (e.g., Resend) for the test outbox.
   *Fix:* `wrangler secret put RESEND_API_KEY`
3. **Cloudflare DNS Token Missing**: You need to add a DNS API token to set up SPF/DKIM/DMARC.
   *Fix:* `wrangler secret put CLOUDFLARE_API_TOKEN`

- **Phase 3**: Create 2 new Paddle Sandbox prices (Monthly, Yearly) and 2 Paystack plans without deleting old ones. Add the price IDs to .dev.vars as PADDLE_MONTHLY_PRICE, PADDLE_YEARLY_PRICE, PAYSTACK_MONTHLY_PLAN, PAYSTACK_YEARLY_PLAN.