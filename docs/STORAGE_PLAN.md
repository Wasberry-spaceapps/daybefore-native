# Day Before — Storage Plan

## Architecture

Every account on every platform uses isolated namespaced storage.  
Every write goes to the primary store AND at least one backup layer.  
No data is ever deleted without a full deleteMyAccount flow.

## Web

| Layer | Engine | Namespace | Survives |
|---|---|---|---|
| 1 Primary | IndexedDB (Dexie) | `DayBeforeDB-{email}` | Browser clear = NO |
| 2 Mirror | OPFS | `/daybefore_{accountId}/` | Browser clear = NO |
| 3 Filesystem | File System Access API | User-chosen folder | Browser reinstall = YES |
| 4 SW Cache | Cache API | `daybefore-entries-v1` | Browser clear = NO |

## Native

| Layer | Engine | Namespace | Survives |
|---|---|---|---|
| 1 Primary | SQLite (sqflite) | `daybefore_data_{accountId}.db` | Uninstall = NO |
| 2 Auto Backup | OS Auto Backup | System-managed | Android/iOS = YES |
| 3 Documents | filesystem | `Documents/DayBefore/` | Uninstall = YES |

## Account ID Derivation

- Cloud account: `SHA256(userId)[0..16]` (first 16 hex chars)
- Local account: UUID v4 generated on first launch

## Registry

- Web: IndexedDB `daybefore_registry` → object store `accounts`
- Native: SQLite `daybefore_registry.db` → table `accounts`

Both use the same schema (see registry.ts / registry.dart).

## Backup File Format

Magic: `DBBK` (4 bytes)  
Version: `0x0001` (2 bytes)  
Account hash: SHA-256 of accountId (32 bytes)  
Timestamp: Unix ms (8 bytes, big-endian uint64)  
IV: 12 random bytes  
Ciphertext: AES-256-GCM encrypted JSON payload  
Auth tag: 16 bytes (appended by AES-GCM)

Total overhead: 74 bytes per backup file.

## No-Delete Rules

- `deleteDatabase` / `db.delete()` / `DROP TABLE`: only inside deleteMyAccount()
- `localStorage.clear()`: NEVER
- `FlutterSecureStorage.deleteAll()`: only inside logout (tokens only, not keys)
- Soft-delete pattern: set `isArchived = true` / `deleted = 1`, never hard-delete records
