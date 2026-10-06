// @ts-nocheck
export const deriveKey = async (password: string, salt: Uint8Array): Promise<CryptoKey> => {
  const pristineSalt = salt ? new Uint8Array(salt) : new Uint8Array(16);

  const enc = new TextEncoder();
  const keyMaterial = await window.crypto.subtle.importKey(
    'raw',
    enc.encode(password),
    { name: 'PBKDF2' },
    false,
    ['deriveBits', 'deriveKey']
  );
  return window.crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: pristineSalt,
      iterations: 100000,
      hash: 'SHA-256'
    },
    keyMaterial,
    { name: 'AES-GCM', length: 256 },
    true, // extractable so we can wrap/unwrap if needed
    ['encrypt', 'decrypt', 'wrapKey', 'unwrapKey']
  );
};

export const generateDataKey = async (): Promise<CryptoKey> => {
  return window.crypto.subtle.generateKey(
    { name: 'AES-GCM', length: 256 },
    true,
    ['encrypt', 'decrypt']
  );
};

export const generateRecoveryKey = (): string => {
  // Generate 16 bytes of random data for the recovery key
  const bytes = new Uint8Array(16);
  window.crypto.getRandomValues(bytes);
  // Encode as hex or base32 for the user (we'll use hex for simplicity here, grouped)
  const hex = Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
  return hex.match(/.{1,4}/g)!.join('-');
};

export const deriveRecoveryKey = async (recoveryKeyStr: string): Promise<CryptoKey> => {
  const hex = recoveryKeyStr.replace(/-/g, '');
  const bytes = new Uint8Array(hex.match(/.{1,2}/g)!.map(byte => parseInt(byte, 16)));
  return window.crypto.subtle.importKey(
    'raw',
    bytes,
    { name: 'AES-GCM' },
    true,
    ['wrapKey', 'unwrapKey']
  );
};

export const wrapDataKey = async (dataKey: CryptoKey, wrappingKey: CryptoKey): Promise<string> => {
  const iv = window.crypto.getRandomValues(new Uint8Array(12));
  const wrapped = await window.crypto.subtle.wrapKey(
    'raw',
    dataKey,
    wrappingKey,
    { name: 'AES-GCM', iv }
  );
  
  const payload = new Uint8Array(iv.length + wrapped.byteLength);
  payload.set(iv, 0);
  payload.set(new Uint8Array(wrapped), iv.length);
  
  return btoa(String.fromCharCode.apply(null, Array.from(payload)));
};

export const unwrapDataKey = async (wrappedKeyStr: string, unwrappingKey: CryptoKey): Promise<CryptoKey> => {
  const binary = atob(wrappedKeyStr);
  const payload = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) payload[i] = binary.charCodeAt(i);
  
  const iv = payload.slice(0, 12);
  const wrapped = payload.slice(12);
  
  return window.crypto.subtle.unwrapKey(
    'raw',
    wrapped,
    unwrappingKey,
    { name: 'AES-GCM', iv },
    { name: 'AES-GCM', length: 256 },
    true,
    ['encrypt', 'decrypt']
  );
};

export const encryptData = async (data: string, key: CryptoKey): Promise<string> => {
  const iv = window.crypto.getRandomValues(new Uint8Array(12));
  const enc = new TextEncoder();
  const ciphertext = await window.crypto.subtle.encrypt(
    { name: 'AES-GCM', iv: iv },
    key,
    enc.encode(data)
  );

  const payload = new Uint8Array(iv.length + ciphertext.byteLength);
  payload.set(iv, 0);
  payload.set(new Uint8Array(ciphertext), iv.length);
  
  return btoa(String.fromCharCode.apply(null, Array.from(payload)));
};

export const decryptData = async (ciphertextStr: string, key: CryptoKey): Promise<string> => {
  const binary = atob(ciphertextStr);
  const payload = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) payload[i] = binary.charCodeAt(i);
  
  const iv = payload.slice(0, 12);
  const data = payload.slice(12);
  
  const decrypted = await window.crypto.subtle.decrypt(
    { name: 'AES-GCM', iv: iv },
    key,
    data
  );
  
  const dec = new TextDecoder();
  return dec.decode(decrypted);
};

export const encryptObject = async (obj: any, key: CryptoKey): Promise<string> => {
  return await encryptData(JSON.stringify(obj), key);
};

export const decryptObject = async (ciphertext: string, key: CryptoKey): Promise<any> => {
  const decrypted = await decryptData(ciphertext, key);
  return JSON.parse(decrypted);
};

export const generateSalt = (): Uint8Array => {
  return crypto.getRandomValues(new Uint8Array(16));
};

export const hashPassword = async (password: string): Promise<string> => {
  const enc = new TextEncoder();
  const hashBuffer = await crypto.subtle.digest('SHA-256', enc.encode(password));
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
};
