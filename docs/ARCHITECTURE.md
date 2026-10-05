# Architecture Document

## DB Schema
- **`users`**: Stores `id` (email), `password_hash`, `salt`, `paddle_customer_id`, `paystack_customer_code`.
- **`sync_blobs`**: Stores `id`, `user_id`, `encrypted_payload`, `updated_at`. Used for LWW sync of entries.
- **`subscriptions`**: Stores entitlements: `id`, `user_id`, `provider` (paddle/paystack), `status`, `plan`, `period_end`, `student_until`.

## Authentication Flow
- **Current Flow**: Standard email/password. Password is hashed with a server-side salt.
- **Tokens**: Returns a stateless JWT signed with `JWT_SECRET`. Passed via HTTP `Bearer` header.
- **Planned Changes**: Email verification, Turnstile on signup/login, multi-device token invalidation, versioned envelope for recovery.

## Crypto Implementation
- **Current**: 
  - KDF: `PBKDF2` with `SHA-256`, 100,000 iterations, 32-byte derived key.
  - Cipher: `AES-GCM` (256-bit).
  - IV: 12 bytes randomly generated per payload, prepended to the ciphertext.
  - Serialization: Base64 string `nonce + ciphertext + tag`.
- **Data Key Gap**: Currently, **the data key is derived straight from the user's password**. 
  *Risk:* If a user resets their password via email, they will lose access to all previous data because the server does not know the old password to re-derive the key. 
  *Fix:* We must implement the Versioned Envelope (random data key wrapped by password-derived key + Recovery Key) in Phase 2.

## Native vs Web Apps
- **Web App**: React, Vite, deployed to Cloudflare Pages.
- **Native App**: Flutter (`/native`), sharing the same API and backend crypto.
- Both clients handle E2E encryption locally before syncing to the Worker.
