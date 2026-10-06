// @ts-nocheck
import { db } from './db';
import { encryptObject, decryptObject } from './crypto';

const API_URL = 'https://daybefore-backend.wasberry.workers.dev/api'; // Replace with actual worker URL

export async function syncDatabase(token: string, key: CryptoKey) {
  const lastSyncStr = localStorage.getItem('daybefore_lastSync') || '0';
  const lastSync = parseInt(lastSyncStr, 10);
  const now = Date.now();

  const collections = ['journalEntries', 'corePoints', 'issues', 'issueEntries'] as const;

  for (const collection of collections) {
    // 1. Fetch remote changes since lastSync
    const res = await fetch(`${API_URL}/sync/${collection}?since=${lastSync}`, {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    
    if (!res.ok) {
      if (res.status === 403) {
        console.warn('Subscription required to sync.');
        return; // Abort sync
      }
      continue; // Skip on error
    }

    const { items } = await res.json();
    
    // Decrypt and merge remote changes
    for (const item of items) {
      try {
        const decrypted = await decryptObject(item.encrypted_data, key);
        const existing = await (db as any)[collection].get(item.record_id);
        
        if (!existing || existing.updatedAt < item.updated_at) {
          // Remote is newer, upsert local
          await (db as any)[collection].put({ ...decrypted, id: item.record_id, updatedAt: item.updated_at });
        }
      } catch (e) {
        console.error('Failed to decrypt or merge record:', e);
      }
    }

    // 2. Push local changes since lastSync
    const localChanges = await (db as any)[collection].where('updatedAt').above(lastSync).toArray();
    
    if (localChanges.length > 0) {
      const pushItems = await Promise.all(localChanges.map(async (record: any) => {
        const encrypted_data = await encryptObject(record, key);
        return {
          record_id: record.id,
          encrypted_data,
          updated_at: record.updatedAt
        };
      }));

      await fetch(`${API_URL}/sync/${collection}`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ items: pushItems })
      });
    }
  }

  // Update lastSync
  localStorage.setItem('daybefore_lastSync', now.toString());
}
