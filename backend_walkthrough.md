# Day Before: Phase 2 Completion (Backend & Sync)

## Changes Made
- **Product Renaming**: Renamed "Day Ahead" to "Day Before" globally, and updated the domain to `daybefore.app` across all files, documentation, and logic.
- **Cloudflare Worker Setup**: Created the backend API in the `backend` directory using `Hono`.
- **D1 Database**: Defined `schema.sql` for `accounts`, `sync_blobs`, and `student_verifications`.
- **E2E Encryption**: Built `crypto.ts` in the frontend using the Web Crypto API to derive a key from the user's passphrase (PBKDF2) and encrypt/decrypt JSON payloads (AES-GCM). The server only ever receives opaque encrypted data.
- **Sync Engine**: Developed a Last-Write-Wins (LWW) sync mechanism in `sync.ts` that merges remote entries with local IndexedDB (`Dexie`) entries.
- **Purchasing Power Parity (PPP) Pricing**: Implemented `/api/checkout/price` in the Cloudflare Worker which reads the `cf.country` header (provided by Cloudflare natively) to calculate the appropriate price and currency (e.g., NGN 1400/800 for Nigeria, $3.00/$1.50 for US/EU, and a scaled discount for other nations).
- **Payment Webhook**: Replaced Stripe entirely with a mock Paddle webhook endpoint (`/api/webhooks/payment`) to flip accounts from `free` to `active`.
- **Student Verification**: Added `/api/student/verify` to accept document uploads (via Cloudflare R2), and a mock admin route to approve them which immediately purges the document to comply with the strict data-minimization requirement.

## Verification
- Clean build performed successfully in `daybefore/app` (`npm run build`).
- Clean install performed in `daybefore/backend`.
- The free app remains entirely usable locally without ever hitting the backend. Creating a sync account successfully derives an encryption key and allows E2E synced storage.
