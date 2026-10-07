# Day Before — Storage Progress

## Phase 0 — Audit

### Web Storage (daybefore-web)

Storage engine: Dexie.js (IndexedDB wrapper)

Database name: `DayBeforeDB-${email}` (email-namespaced, set on login/register)

Object stores:
- `journalEntries` — key: id, indexes: createdAt, updatedAt
- `corePoints` — key: id, indexes: createdAt, updatedAt
- `issues` — key: id, indexes: isArchived, createdAt, updatedAt
- `issueEntries` — key: id, indexes: issueId, createdAt, updatedAt

localStorage keys:
- `daybefore_token` — auth JWT
- `daybefore_salt` — PBKDF2 salt (base64)
- `daybefore_wrappedKeyPwd` — V2 wrapped data key
- `daybefore_email` — email (for DB namespace)
- `daybefore_leftPanel` — UI pref
- `daybefore_journalCol` — UI pref
- `daybefore_coreCol` — UI pref
- `daybefore_issuesCol` — UI pref

Deletion code paths found:
- `App.tsx` logout: removes token, salt, wrappedKeyPwd, email from localStorage (correct — no DB delete)
- No `indexedDB.deleteDatabase` calls found in source ✓
- No `localStorage.clear()` calls found ✓
- No `db.delete()` without WHERE found ✓

### Native Storage (daybefore-native)

Storage engine: sqflite (SQLite)

Database: `{appDocumentsDir}/daybefore_data_{accountId}.db`

Tables: journal_entries, core_points, issues, issue_entries

Registry: `{appDocumentsDir}/daybefore_registry.db` → table: accounts

Secure storage keys: token, salt, email, wrappedKeyPwd

Deletion code paths:
- `auth_provider.dart` logout: `FlutterSecureStorage().deleteAll()` — only deletes tokens
- No `deleteDatabase` calls found ✓

---

## Phase 1 — Multi-Account Namespace Isolation

### Web
- [x] DB namespaced by email (`DayBeforeDB-${email}`)
- [ ] IndexedDB registry (`daybefore_registry`)
- [ ] userId-hash-based accountId (currently uses email)
- [ ] localStorage key namespacing
- [ ] Migration from old un-namespaced DB

### Native
- [x] SQLite registry (`daybefore_registry.db`, `AccountRegistry` class)
- [x] Local-only UUID account creation
- [x] `recordLogin()` for cloud accounts
- [x] `setActiveAccountId()` / `getActiveAccountId()`
- [x] DB namespaced by accountId (`daybefore_data_{accountId}.db`)

Status: **Native DONE. Web partial.**

---

## Phase 2 — Web Redundant Storage

- [ ] Layer 1: IndexedDB primary (exists, needs write error handling)
- [ ] Layer 2: OPFS mirror
- [ ] Layer 3: File System Access API backup
- [ ] Layer 4: Service Worker cache (top 20 entries)
- [ ] Layer 5: Persistent storage request

Status: **Not started.**

---

## Phase 3 — Native Redundant Storage

- [x] Layer 1: SQLite primary (`daybefore_data_{accountId}.db`)
- [ ] Layer 2: Android Auto Backup XMLs
- [x] Layer 3: BackupManager (Desktop: Documents/DayBefore, Android: MediaStore, iOS: app docs)
- [ ] Layer 3: BackupChannel.kt (Kotlin platform channel for Android MediaStore)
- [ ] Layer 4: iOS iCloud container
- [x] Layer 5: BackupScanner (scan on launch if DB missing)
- [x] Integrity check on launch (PRAGMA integrity_check)

Status: **Partially done. Android Auto Backup and BackupChannel.kt missing.**

---

## Phase 4 — Backup File Format

- [ ] DBBK binary format (cross-platform)
- [ ] Web createBackup() / restoreBackup()
- [ ] Dart createBackup() / restoreBackup()

Status: **Not started.**

---

## Phase 5 — Data Integrity and UI

- [x] Native: integrity check on launch (storage.dart)
- [ ] Web: integrity check on launch
- [ ] Checksum .sha256 sidecar
- [ ] Backup UI in Account screen
- [ ] Switch account screen

Status: **Native partially done.**

---

## Phase 6 — Testing

- [ ] Unit tests: namespace isolation, backup round-trip, corrupt backup handling
- [ ] Widget tests: backup UI, switch account

Status: **Not started.**
