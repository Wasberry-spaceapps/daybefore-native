// IndexedDB registry — tracks all accounts ever used on this device.
// Uses a separate DB that is NOT namespaced (it's the namespace manager itself).

const REGISTRY_DB_NAME = 'daybefore_registry';
const REGISTRY_VERSION = 1;

export interface AccountRecord {
  accountId: string;
  type: 'cloud' | 'local';
  email: string | null;
  displayName: string | null;
  createdAt: number;
  lastAccessedAt: number;
  entryCount: number;
  storageBytes: number;
}

let _db: IDBDatabase | null = null;

async function openRegistryDB(): Promise<IDBDatabase> {
  if (_db) return _db;
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(REGISTRY_DB_NAME, REGISTRY_VERSION);
    req.onupgradeneeded = e => {
      const db = (e.target as IDBOpenDBRequest).result;
      if (!db.objectStoreNames.contains('accounts')) {
        db.createObjectStore('accounts', { keyPath: 'accountId' });
      }
      if (!db.objectStoreNames.contains('backupHandles')) {
        db.createObjectStore('backupHandles', { keyPath: 'accountId' });
      }
    };
    req.onsuccess = e => { _db = (e.target as IDBOpenDBRequest).result; resolve(_db!); };
    req.onerror = () => reject(req.error);
  });
}

export async function getActiveAccountId(): Promise<string | null> {
  return localStorage.getItem('daybefore_active_account');
}

export async function setActiveAccountId(id: string): Promise<void> {
  localStorage.setItem('daybefore_active_account', id);
}

export async function getOrCreateLocalAccount(): Promise<string> {
  const existing = await getActiveAccountId();
  if (existing) {
    const acc = await getAccount(existing);
    if (acc) return existing;
  }
  const id = crypto.randomUUID();
  const now = Date.now();
  await upsertAccount({
    accountId: id,
    type: 'local',
    email: null,
    displayName: null,
    createdAt: now,
    lastAccessedAt: now,
    entryCount: 0,
    storageBytes: 0,
  });
  await setActiveAccountId(id);
  return id;
}

export async function recordLogin(accountId: string, email: string): Promise<void> {
  const existing = await getAccount(accountId);
  const now = Date.now();
  await upsertAccount({
    accountId,
    type: 'cloud',
    email,
    displayName: null,
    createdAt: existing?.createdAt ?? now,
    lastAccessedAt: now,
    entryCount: existing?.entryCount ?? 0,
    storageBytes: existing?.storageBytes ?? 0,
  });
  await setActiveAccountId(accountId);
}

async function getAccount(accountId: string): Promise<AccountRecord | null> {
  const db = await openRegistryDB();
  return new Promise((resolve, reject) => {
    const req = db.transaction('accounts', 'readonly').objectStore('accounts').get(accountId);
    req.onsuccess = () => resolve(req.result ?? null);
    req.onerror = () => reject(req.error);
  });
}

async function upsertAccount(record: AccountRecord): Promise<void> {
  const db = await openRegistryDB();
  return new Promise((resolve, reject) => {
    const req = db.transaction('accounts', 'readwrite').objectStore('accounts').put(record);
    req.onsuccess = () => resolve();
    req.onerror = () => reject(req.error);
  });
}

export async function getAllAccounts(): Promise<AccountRecord[]> {
  const db = await openRegistryDB();
  return new Promise((resolve, reject) => {
    const req = db.transaction('accounts', 'readonly').objectStore('accounts').getAll();
    req.onsuccess = () => resolve((req.result as AccountRecord[]).sort((a, b) => b.lastAccessedAt - a.lastAccessedAt));
    req.onerror = () => reject(req.error);
  });
}

export async function storeBackupHandle(accountId: string, handle: FileSystemDirectoryHandle): Promise<void> {
  const db = await openRegistryDB();
  return new Promise((resolve, reject) => {
    const req = db.transaction('backupHandles', 'readwrite').objectStore('backupHandles').put({ accountId, handle });
    req.onsuccess = () => resolve();
    req.onerror = () => reject(req.error);
  });
}

export async function getBackupHandle(accountId: string): Promise<FileSystemDirectoryHandle | null> {
  const db = await openRegistryDB();
  return new Promise((resolve, reject) => {
    const req = db.transaction('backupHandles', 'readonly').objectStore('backupHandles').get(accountId);
    req.onsuccess = () => resolve(req.result?.handle ?? null);
    req.onerror = () => reject(req.error);
  });
}
