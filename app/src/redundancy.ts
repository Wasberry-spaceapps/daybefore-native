// Redundant storage for the web app: OPFS mirror + File System Access API backup.
// All functions are fire-and-forget from the caller's perspective — they never block the UI.

import { getBackupHandle, storeBackupHandle } from './registry';

// ─── Layer 2: OPFS Mirror ────────────────────────────────────────────────────

export async function mirrorToOPFS(
  accountId: string,
  storeName: string,
  record: Record<string, unknown>
): Promise<void> {
  try {
    const root = await navigator.storage.getDirectory();
    const accountDir = await root.getDirectoryHandle(`daybefore_${accountId}`, { create: true });
    const storeDir = await accountDir.getDirectoryHandle(storeName, { create: true });
    const fileHandle = await storeDir.getFileHandle(`${record['id']}.json`, { create: true });
    const writable = await fileHandle.createWritable();
    await writable.write(JSON.stringify(record));
    await writable.close();
  } catch (e) {
    // OPFS unavailable or quota exceeded — non-fatal
    console.warn('OPFS mirror failed:', (e as Error).name);
  }
}

export async function deleteFromOPFS(accountId: string, storeName: string, id: string): Promise<void> {
  try {
    const root = await navigator.storage.getDirectory();
    const accountDir = await root.getDirectoryHandle(`daybefore_${accountId}`, { create: false });
    const storeDir = await accountDir.getDirectoryHandle(storeName, { create: false });
    await storeDir.removeEntry(`${id}.json`);
  } catch {
    // ignore — file may not exist in OPFS
  }
}

export async function restoreFromOPFS(
  accountId: string,
  storeName: string
): Promise<Record<string, unknown>[]> {
  const records: Record<string, unknown>[] = [];
  try {
    const root = await navigator.storage.getDirectory();
    const accountDir = await root.getDirectoryHandle(`daybefore_${accountId}`, { create: false });
    const storeDir = await accountDir.getDirectoryHandle(storeName, { create: false });
    for await (const [, handle] of (storeDir as any).entries()) {
      if (handle.kind === 'file') {
        const file = await handle.getFile();
        const text = await file.text();
        try { records.push(JSON.parse(text)); } catch { /* corrupt file */ }
      }
    }
  } catch {
    // directory doesn't exist
  }
  return records;
}

// ─── Layer 3: File System Access API Backup ──────────────────────────────────

let _backupDirty = false;
let _lastBackupTime = 0;
let _backupInFlight = false;

export function markBackupDirty(): void {
  _backupDirty = true;
}

export function getLastBackupTime(): number {
  return _lastBackupTime;
}

// Call once on app start — sets up periodic + visibilitychange triggers
export function startBackupScheduler(
  accountId: string,
  exportFn: () => Promise<Uint8Array>
): void {
  // every 5 minutes if dirty
  setInterval(() => {
    if (_backupDirty) writeBackup(accountId, exportFn);
  }, 5 * 60 * 1000);

  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'hidden' && _backupDirty) {
      writeBackup(accountId, exportFn);
    }
  });

  window.addEventListener('beforeunload', () => {
    if (_backupDirty) writeBackup(accountId, exportFn);
  });
}

export async function writeBackup(
  accountId: string,
  exportFn: () => Promise<Uint8Array>
): Promise<boolean> {
  if (_backupInFlight) return false;
  const dirHandle = await getBackupHandle(accountId);
  if (!dirHandle) return false;

  try {
    // Check permission (cast to any — FileSystemDirectoryHandle has queryPermission/requestPermission at runtime)
    const dirAny = dirHandle as any;
    let perm = await dirAny.queryPermission({ mode: 'readwrite' });
    if (perm !== 'granted') {
      perm = await dirAny.requestPermission({ mode: 'readwrite' });
      if (perm !== 'granted') return false;
    }

    _backupInFlight = true;
    const data = await exportFn();
    const dataBuffer = data.buffer as ArrayBuffer;
    const timestamp = Date.now();
    const fileName = `DayBefore-backup-${accountId}-${timestamp}.enc`;
    const fileHandle = await dirHandle.getFileHandle(fileName, { create: true });
    const writable = await fileHandle.createWritable();
    await writable.write(dataBuffer);
    await writable.close();

    // Write .sha256 sidecar
    const hashBuf = await crypto.subtle.digest('SHA-256', dataBuffer);
    const hashHex = Array.from(new Uint8Array(hashBuf)).map(b => b.toString(16).padStart(2, '0')).join('');
    const shaHandle = await dirHandle.getFileHandle(`${fileName}.sha256`, { create: true });
    const shaWritable = await shaHandle.createWritable();
    await shaWritable.write(new TextEncoder().encode(`${hashHex}  ${fileName}`).buffer as ArrayBuffer);
    await shaWritable.close();

    // Keep only last 5 backups
    const entries: { name: string; handle: FileSystemFileHandle }[] = [];
    for await (const [name, handle] of (dirHandle as any).entries()) {
      if (name.startsWith(`DayBefore-backup-${accountId}-`) && name.endsWith('.enc')) {
        entries.push({ name, handle });
      }
    }
    entries.sort((a, b) => b.name.localeCompare(a.name));
    for (const old of entries.slice(5)) {
      try {
        await dirHandle.removeEntry(old.name);
        await dirHandle.removeEntry(`${old.name}.sha256`);
      } catch { /* entry may already be gone */ }
    }

    _backupDirty = false;
    _lastBackupTime = timestamp;
    return true;
  } catch (e) {
    console.warn('Filesystem backup failed:', e);
    return false;
  } finally {
    _backupInFlight = false;
  }
}

export async function listFilesystemBackups(
  accountId: string
): Promise<{ name: string; size: number; lastModified: number }[]> {
  const dirHandle = await getBackupHandle(accountId);
  if (!dirHandle) return [];
  try {
    const backups: { name: string; size: number; lastModified: number }[] = [];
    for await (const [name, handle] of (dirHandle as any).entries()) {
      if (handle.kind === 'file' && name.startsWith(`DayBefore-backup-${accountId}-`) && name.endsWith('.enc')) {
        const file = await handle.getFile();
        backups.push({ name, size: file.size, lastModified: file.lastModified });
      }
    }
    return backups.sort((a, b) => b.lastModified - a.lastModified);
  } catch {
    return [];
  }
}

// Show a prompt to choose a backup folder (first-time setup)
export async function setupBackupFolder(accountId: string): Promise<boolean> {
  if (!('showDirectoryPicker' in window)) return false;
  try {
    const dirHandle = await (window as any).showDirectoryPicker({ mode: 'readwrite' });
    await storeBackupHandle(accountId, dirHandle);
    return true;
  } catch {
    return false; // user cancelled
  }
}

// ─── Layer 5: Persistent storage ─────────────────────────────────────────────

export async function requestPersistentStorage(): Promise<void> {
  try {
    if (navigator.storage?.persist) {
      await navigator.storage.persist();
    }
  } catch {
    // ignore
  }
}

// ─── Full account data export (plaintext JSON for backup encryption) ─────────

export async function exportAllAccountData(db: any): Promise<object> {
  const [journalEntries, corePoints, issues, issueEntries] = await Promise.all([
    db.journalEntries.toArray(),
    db.corePoints.toArray(),
    db.issues.toArray(),
    db.issueEntries.toArray(),
  ]);
  return { version: 1, exportedAt: Date.now(), journalEntries, corePoints, issues, issueEntries };
}

// ─── Backup file format: DBBK v1 ─────────────────────────────────────────────
// Encryption uses the in-memory e2eKey (= data key).
// Restore flow: user logs in → gets e2eKey → app restores from backup file.

export async function encryptBackup(
  allData: object,
  e2eKey: CryptoKey,
  accountId: string
): Promise<Uint8Array> {
  const payload = new TextEncoder().encode(JSON.stringify(allData));
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const encrypted = new Uint8Array(await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, e2eKey, payload));

  const accountHashBuf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(accountId));
  const accountHash = new Uint8Array(accountHashBuf);
  const tsView = new DataView(new ArrayBuffer(8));
  tsView.setBigUint64(0, BigInt(Date.now()));

  const header = new Uint8Array(58);
  header.set([0x44, 0x42, 0x42, 0x4B], 0); // DBBK
  header.set([0x00, 0x01], 4);               // version 1
  header.set(accountHash, 6);
  header.set(new Uint8Array(tsView.buffer), 38);
  header.set(iv, 46);

  const result = new Uint8Array(58 + encrypted.byteLength);
  result.set(header, 0);
  result.set(encrypted, 58);
  return result;
}

export async function decryptBackup(
  fileBytes: Uint8Array,
  e2eKey: CryptoKey
): Promise<object> {
  if (fileBytes[0] !== 0x44 || fileBytes[1] !== 0x42 || fileBytes[2] !== 0x42 || fileBytes[3] !== 0x4B) {
    throw new Error('Not a valid Day Before backup file.');
  }
  const iv = fileBytes.slice(46, 58);
  const ciphertext = fileBytes.slice(58);
  try {
    const decrypted = await crypto.subtle.decrypt({ name: 'AES-GCM', iv }, e2eKey, ciphertext);
    return JSON.parse(new TextDecoder().decode(decrypted));
  } catch {
    throw new Error('Backup could not be decrypted. Check that you are signed into the correct account.');
  }
}
