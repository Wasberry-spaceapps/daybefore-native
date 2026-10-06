const fs = require('fs');
const cryptoTs = fs.readFileSync('src/crypto.ts', 'utf8');
const newCryptoTs = cryptoTs.replace(
  /export const deriveKey = async \(password: string, salt: Uint8Array\): Promise<CryptoKey> => \{[\s\S]*?return window.crypto.subtle.deriveKey\(/,
  \export const deriveKey = async (password: string, salt: Uint8Array): Promise<CryptoKey> => {
  const pristineSalt = new Uint8Array(salt || 16);

  const enc = new TextEncoder();
  const keyMaterial = await window.crypto.subtle.importKey(
    'raw',
    enc.encode(password),
    { name: 'PBKDF2' },
    false,
    ['deriveBits', 'deriveKey']
  );
  return window.crypto.subtle.deriveKey(\
);
const fixedCryptoTs = newCryptoTs.replace(
  /name: 'PBKDF2',\s*salt: salt,/,
  \"name: 'PBKDF2',\\n      salt: pristineSalt,\"
);
fs.writeFileSync('src/crypto.ts', fixedCryptoTs);
