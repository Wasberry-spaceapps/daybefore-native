const fs = require('fs');
const path = require('path');

const projectRoot = 'D:\\daybefore-native\\native';

const files = {
  'pubspec.yaml': `name: daybefore
description: A private journal for getting better.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cryptography: ^2.7.0
  sqflite: ^2.3.3
  sqflite_common_ffi: ^2.3.3
  path_provider: ^2.1.3
  flutter_secure_storage: ^9.2.2
  http: ^1.2.1
  uuid: ^4.4.2
  url_launcher: ^6.3.0
  shared_preferences: ^2.2.3
  provider: ^6.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
`,
  'lib/models/journal_entry.dart': `
class JournalEntry {
  final String id;
  String content;
  final int createdAt;
  int updatedAt;

  JournalEntry({required this.id, required this.content, required this.createdAt, required this.updatedAt});

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'], content: json['content'] ?? '',
    createdAt: json['createdAt'], updatedAt: json['updatedAt'],
  );
  Map<String, dynamic> toJson() => {'id': id, 'content': content, 'createdAt': createdAt, 'updatedAt': updatedAt};
  Map<String, dynamic> toMap() => toJson();
  factory JournalEntry.fromMap(Map<String, dynamic> m) => JournalEntry.fromJson(m);
}
`,
  'lib/models/core_point.dart': `
class CorePoint {
  final String id;
  final String name;
  String content;
  final int createdAt;
  int updatedAt;

  CorePoint({required this.id, required this.name, required this.content, required this.createdAt, required this.updatedAt});

  factory CorePoint.fromJson(Map<String, dynamic> json) => CorePoint(
    id: json['id'], name: json['name'] ?? '', content: json['content'] ?? '',
    createdAt: json['createdAt'], updatedAt: json['updatedAt'],
  );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'content': content, 'createdAt': createdAt, 'updatedAt': updatedAt};
  Map<String, dynamic> toMap() => toJson();
  factory CorePoint.fromMap(Map<String, dynamic> m) => CorePoint.fromJson(m);
}
`,
  'lib/models/issue.dart': `
class Issue {
  final String id;
  final String name;
  String content;
  final int isArchived;
  final int createdAt;
  int updatedAt;

  Issue({required this.id, required this.name, required this.content, required this.isArchived, required this.createdAt, required this.updatedAt});

  factory Issue.fromJson(Map<String, dynamic> json) => Issue(
    id: json['id'], name: json['name'] ?? '', content: json['content'] ?? '',
    isArchived: (json['isArchived'] == true || json['isArchived'] == 1) ? 1 : 0,
    createdAt: json['createdAt'], updatedAt: json['updatedAt'],
  );
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'content': content, 'isArchived': isArchived, 'createdAt': createdAt, 'updatedAt': updatedAt};
  Map<String, dynamic> toMap() => toJson();
  factory Issue.fromMap(Map<String, dynamic> m) => Issue.fromJson(m);
}
`,
  'lib/models/issue_entry.dart': `
class IssueEntry {
  final String id;
  final String issueId;
  String content;
  final int createdAt;
  int updatedAt;

  IssueEntry({required this.id, required this.issueId, required this.content, required this.createdAt, required this.updatedAt});

  factory IssueEntry.fromJson(Map<String, dynamic> json) => IssueEntry(
    id: json['id'], issueId: json['issueId'] ?? '', content: json['content'] ?? '',
    createdAt: json['createdAt'], updatedAt: json['updatedAt'],
  );
  Map<String, dynamic> toJson() => {'id': id, 'issueId': issueId, 'content': content, 'createdAt': createdAt, 'updatedAt': updatedAt};
  Map<String, dynamic> toMap() => toJson();
  factory IssueEntry.fromMap(Map<String, dynamic> m) => IssueEntry.fromJson(m);
}
`,
  'lib/core/crypto.dart': `
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class DayBeforeCrypto {
  static final _rng = Random.secure();

  static Future<String> hashPassword(String passphrase) async {
    final sha256 = Sha256();
    final hash = await sha256.hash(utf8.encode(passphrase));
    return hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  static Uint8List generateSalt() =>
      Uint8List.fromList(List.generate(16, (_) => _rng.nextInt(256)));

  static Future<SecretKey> deriveKey(String passphrase, Uint8List salt) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    return pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  static Future<String> encryptObject(Map<String, dynamic> obj, SecretKey key) async {
    final aes = AesGcm.with256bits();
    final plaintext = utf8.encode(jsonEncode(obj));
    final secretBox = await aes.encrypt(plaintext, secretKey: key);
    final nonce = secretBox.nonce;
    final ct = secretBox.cipherText;
    final mac = secretBox.mac.bytes;
    final payload = Uint8List(12 + ct.length + 16);
    payload.setAll(0, nonce);
    payload.setAll(12, ct);
    payload.setAll(12 + ct.length, mac);
    return base64Encode(payload);
  }

  static Future<Map<String, dynamic>> decryptObject(String base64Payload, SecretKey key) async {
    final aes = AesGcm.with256bits();
    final payload = base64Decode(base64Payload);
    final nonce = payload.sublist(0, 12);
    final cipherAndTag = payload.sublist(12);
    final cipherText = cipherAndTag.sublist(0, cipherAndTag.length - 16);
    final mac = Mac(cipherAndTag.sublist(cipherAndTag.length - 16));
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: mac);
    final plainBytes = await aes.decrypt(secretBox, secretKey: key);
    return jsonDecode(utf8.decode(plainBytes)) as Map<String, dynamic>;
  }

  static String saltToBase64(Uint8List salt) => base64Encode(salt);
  static Uint8List saltFromBase64(String b64) =>
      Uint8List.fromList(base64Decode(b64));
}
`,
  'lib/core/api.dart': `
import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscriptionRequired implements Exception {}
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class ApiClient {
  static const baseUrl = 'https://daybefore-backend.officialmutairu.workers.dev/api';
  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> register(String email, String pwHash, String saltB64) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({'email': email, 'passwordHash': pwHash, 'salt': saltB64}));
    if (res.statusCode != 200) throw ApiException(res.body);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> login(String email, String pwHash) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'passwordHash': pwHash}));
    if (res.statusCode != 200) throw ApiException(res.body);
    return jsonDecode(res.body);
  }

  Future<List<Map<String, dynamic>>> pullSync(String collection, int since) async {
    final res = await http.get(Uri.parse('$baseUrl/sync/$collection?since=$since'), headers: _headers);
    if (res.statusCode == 403) throw SubscriptionRequired();
    if (res.statusCode != 200) throw ApiException(res.body);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body)['items'] ?? []);
  }

  Future<void> pushSync(String collection, List<Map<String, dynamic>> items) async {
    final res = await http.post(Uri.parse('$baseUrl/sync/$collection'),
        headers: _headers, body: jsonEncode({'items': items}));
    if (res.statusCode == 403) throw SubscriptionRequired();
  }
}
`,
  'lib/core/storage.dart': `
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

class LocalDb {
  late Database _db;

  Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dir = await getApplicationDocumentsDirectory();
    _db = await openDatabase('\${dir.path}/daybefore.db', version: 1,
        onCreate: (db, v) async {
      await db.execute('''CREATE TABLE journal_entries (
        id TEXT PRIMARY KEY, content TEXT NOT NULL DEFAULT '',
        createdAt INTEGER, updatedAt INTEGER)''');
      await db.execute('''CREATE TABLE core_points (
        id TEXT PRIMARY KEY, name TEXT NOT NULL, content TEXT NOT NULL DEFAULT '',
        createdAt INTEGER, updatedAt INTEGER)''');
      await db.execute('''CREATE TABLE issues (
        id TEXT PRIMARY KEY, name TEXT NOT NULL, content TEXT DEFAULT '',
        isArchived INTEGER DEFAULT 0,
        createdAt INTEGER, updatedAt INTEGER)''');
      await db.execute('''CREATE TABLE issue_entries (
        id TEXT PRIMARY KEY, issueId TEXT NOT NULL, content TEXT NOT NULL DEFAULT '',
        createdAt INTEGER, updatedAt INTEGER)''');
    });
  }

  Future<List<Map<String, dynamic>>> getAll(String table, {String orderBy = 'createdAt DESC'}) async =>
      _db.query(table, orderBy: orderBy);

  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final rows = await _db.query(table, where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> upsert(String table, Map<String, dynamic> row) async =>
      _db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);

  Future<void> upsertIfNewer(String table, Map<String, dynamic> row) async {
    final existing = await getById(table, row['id']);
    if (existing == null || (existing['updatedAt'] ?? 0) < (row['updatedAt'] ?? 0)) {
      await upsert(table, row);
    }
  }

  Future<void> delete(String table, String id) async =>
      _db.delete(table, where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getChangedSince(String table, int since) async =>
      _db.query(table, where: 'updatedAt > ?', whereArgs: [since]);
}
`,
  'lib/core/sync.dart': `
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';
import 'crypto.dart';
import 'storage.dart';
import 'package:cryptography/cryptography.dart';

class SyncEngine {
  final ApiClient api;
  final LocalDb db;
  final SecretKey encryptionKey;

  SyncEngine({required this.api, required this.db, required this.encryptionKey});

  static const _collections = {
    'journalEntries': 'journal_entries',
    'corePoints': 'core_points',
    'issues': 'issues',
    'issueEntries': 'issue_entries',
  };

  Future<bool> sync() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt('daybefore_lastSync') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    bool success = true;

    for (final entry in _collections.entries) {
      final apiName = entry.key;
      final tableName = entry.value;

      try {
        final remoteItems = await api.pullSync(apiName, lastSync);
        for (final item in remoteItems) {
          final decrypted = await DayBeforeCrypto.decryptObject(
              item['encrypted_data'] as String, encryptionKey);
          decrypted['id'] = item['record_id'];
          decrypted['updatedAt'] = item['updated_at'];
          await db.upsertIfNewer(tableName, decrypted);
        }
      } on SubscriptionRequired {
        return false;
      } catch (e) {
        success = false;
      }

      try {
        final localChanges = await db.getChangedSince(tableName, lastSync);
        if (localChanges.isNotEmpty) {
          final pushItems = await Future.wait(localChanges.map((record) async {
            final encrypted = await DayBeforeCrypto.encryptObject(record, encryptionKey);
            return {
              'record_id': record['id'],
              'encrypted_data': encrypted,
              'updated_at': record['updatedAt'],
            };
          }));
          await api.pushSync(apiName, pushItems);
        }
      } on SubscriptionRequired {
        return false;
      } catch (e) {
        success = false;
      }
    }
    
    if (success) {
      await prefs.setInt('daybefore_lastSync', now);
    }
    return true;
  }
}
`,
  'lib/features/auth/auth_provider.dart': `
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';
import '../../core/api.dart';
import '../../core/crypto.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient api;
  String? token;
  SecretKey? encryptionKey;
  bool get isLoggedIn => token != null;

  AuthProvider({required this.api});

  Future<void> login(String email, String password) async {
    final pwHash = await DayBeforeCrypto.hashPassword(password);
    final data = await api.login(email, pwHash);
    token = data['token'] as String;
    api.setToken(token!);
    final salt = DayBeforeCrypto.saltFromBase64(data['salt'] as String);
    encryptionKey = await DayBeforeCrypto.deriveKey(password, salt);
    final storage = const FlutterSecureStorage();
    await storage.write(key: 'token', value: token);
    await storage.write(key: 'salt', value: data['salt'] as String);
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    final pwHash = await DayBeforeCrypto.hashPassword(password);
    final salt = DayBeforeCrypto.generateSalt();
    final saltB64 = DayBeforeCrypto.saltToBase64(salt);
    final data = await api.register(email, pwHash, saltB64);
    token = data['token'] as String;
    api.setToken(token!);
    encryptionKey = await DayBeforeCrypto.deriveKey(password, salt);
    final storage = const FlutterSecureStorage();
    await storage.write(key: 'token', value: token);
    await storage.write(key: 'salt', value: data['salt'] as String);
    notifyListeners();
  }

  Future<void> tryRestoreSession(String password) async {
    final storage = const FlutterSecureStorage();
    token = await storage.read(key: 'token');
    final saltB64 = await storage.read(key: 'salt');
    if (token != null && saltB64 != null) {
      api.setToken(token!);
      encryptionKey = await DayBeforeCrypto.deriveKey(
          password, DayBeforeCrypto.saltFromBase64(saltB64));
      notifyListeners();
    }
  }

  Future<void> logout() async {
    token = null;
    encryptionKey = null;
    await const FlutterSecureStorage().deleteAll();
    notifyListeners();
  }
}
`,
  'lib/ui/theme.dart': `
import 'package:flutter/material.dart';

final darkTheme = ThemeData.dark().copyWith(
  scaffoldBackgroundColor: const Color(0xFF12100E),
  cardColor: const Color(0xFF161412),
  dividerColor: const Color(0xFF333333),
  textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'serif'),
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    secondary: Color(0xFFA0A0A0),
    surface: Color(0xFF12100E),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF12100E),
    elevation: 0,
  ),
);
`,
  'lib/ui/app_shell.dart': `
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../core/storage.dart';
import '../core/api.dart';
import '../core/sync.dart';
import '../models/journal_entry.dart';
import '../models/core_point.dart';
import '../models/issue.dart';
import '../features/auth/auth_provider.dart';
import 'theme.dart';

class AppState extends ChangeNotifier {
  final LocalDb db;
  final AuthProvider auth;

  List<JournalEntry> journals = [];
  List<CorePoint> corePoints = [];
  List<Issue> issues = [];

  String? activeType;
  String? activeId;
  String draftContent = '';
  Timer? _debounce;
  bool isSyncing = false;

  AppState({required this.db, required this.auth}) {
    loadAll();
  }

  Future<void> loadAll() async {
    journals = (await db.getAll('journal_entries')).map((e) => JournalEntry.fromMap(e)).toList();
    corePoints = (await db.getAll('core_points', orderBy: 'createdAt ASC')).map((e) => CorePoint.fromMap(e)).toList();
    issues = (await db.getAll('issues', orderBy: 'createdAt ASC')).map((e) => Issue.fromMap(e)).where((i) => i.isArchived == 0).toList();
    notifyListeners();
  }

  void setActive(String type, String id, String content) {
    activeType = type;
    activeId = id;
    draftContent = content;
    notifyListeners();
  }

  void updateDraft(String content) {
    draftContent = content;
    notifyListeners();
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () async {
      if (activeType != null && activeId != null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (activeType == 'journal') {
          final entry = journals.firstWhere((e) => e.id == activeId);
          entry.content = draftContent;
          entry.updatedAt = now;
          await db.upsert('journal_entries', entry.toMap());
        } else if (activeType == 'core') {
          final entry = corePoints.firstWhere((e) => e.id == activeId);
          entry.content = draftContent;
          entry.updatedAt = now;
          await db.upsert('core_points', entry.toMap());
        } else if (activeType == 'issue') {
          final entry = issues.firstWhere((e) => e.id == activeId);
          entry.content = draftContent;
          entry.updatedAt = now;
          await db.upsert('issues', entry.toMap());
        }
        await loadAll();
        runSync();
      }
    });
  }

  Future<void> runSync() async {
    if (!auth.isLoggedIn || auth.encryptionKey == null || isSyncing) return;
    isSyncing = true;
    notifyListeners();
    
    final engine = SyncEngine(api: auth.api, db: db, encryptionKey: auth.encryptionKey!);
    final success = await engine.sync();
    
    isSyncing = false;
    await loadAll();
    notifyListeners();
  }

  Future<void> createJournal() async {
    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final entry = JournalEntry(id: id, content: '', createdAt: now, updatedAt: now);
    await db.upsert('journal_entries', entry.toMap());
    await loadAll();
    setActive('journal', id, '');
    runSync();
  }

  Future<void> createCorePoint(String name) async {
    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final entry = CorePoint(id: id, name: name, content: '', createdAt: now, updatedAt: now);
    await db.upsert('core_points', entry.toMap());
    await loadAll();
    setActive('core', id, '');
    runSync();
  }

  Future<void> createIssue(String name) async {
    final id = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;
    final entry = Issue(id: id, name: name, content: '', isArchived: 0, createdAt: now, updatedAt: now);
    await db.upsert('issues', entry.toMap());
    await loadAll();
    setActive('issue', id, '');
    runSync();
  }
}

class AppShell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 768) {
        return Scaffold(
          body: Row(
            children: [
              SizedBox(width: 320, child: Sidebar()),
              const VerticalDivider(width: 1),
              Expanded(child: EditorArea()),
            ],
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Day Before'),
          ),
          drawer: Drawer(child: Sidebar()),
          body: EditorArea(),
        );
      }
    });
  }
}

class Sidebar extends StatefulWidget {
  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? creatingType;
  final TextEditingController _ctrl = TextEditingController();

  void submitCreate(AppState state) {
    if (_ctrl.text.trim().isNotEmpty) {
      if (creatingType == 'core') state.createCorePoint(_ctrl.text.trim());
      if (creatingType == 'issue') state.createIssue(_ctrl.text.trim());
    }
    setState(() { creatingType = null; _ctrl.clear(); });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final auth = context.watch<AuthProvider>();
    
    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Day Before', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => state.createJournal(),
                  child: const Text('New Entry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ExpansionTile(
                  title: const Text('JOURNAL HISTORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  initiallyExpanded: true,
                  children: state.journals.map((e) {
                    final d = DateTime.fromMillisecondsSinceEpoch(e.createdAt);
                    return ListTile(
                      title: Text('\${d.year}-\${d.month.toString().padLeft(2,'0')}-\${d.day.toString().padLeft(2,'0')} \${d.hour.toString().padLeft(2,'0')}\${d.minute.toString().padLeft(2,'0')}'),
                      subtitle: Text(e.content.length > 30 ? e.content.substring(0, 30) : e.content, maxLines: 1),
                      selected: state.activeType == 'journal' && state.activeId == e.id,
                      onTap: () => state.setActive('journal', e.id, e.content),
                    );
                  }).toList(),
                ),
                ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('CORE POINTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => setState(() { creatingType = 'core'; _ctrl.clear(); }),
                      )
                    ],
                  ),
                  initiallyExpanded: true,
                  children: [
                    if (creatingType == 'core')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _ctrl,
                          autofocus: true,
                          decoration: const InputDecoration(hintText: 'Name...'),
                          onSubmitted: (_) => submitCreate(state),
                        ),
                      ),
                    ...state.corePoints.map((e) => ListTile(
                      title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(e.content.length > 30 ? e.content.substring(0, 30) : e.content, maxLines: 1),
                      selected: state.activeType == 'core' && state.activeId == e.id,
                      onTap: () => state.setActive('core', e.id, e.content),
                    ))
                  ],
                ),
                ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ISSUES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () => setState(() { creatingType = 'issue'; _ctrl.clear(); }),
                      )
                    ],
                  ),
                  initiallyExpanded: true,
                  children: [
                    if (creatingType == 'issue')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _ctrl,
                          autofocus: true,
                          decoration: const InputDecoration(hintText: 'Name...'),
                          onSubmitted: (_) => submitCreate(state),
                        ),
                      ),
                    ...state.issues.map((e) => ListTile(
                      title: Text(e.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(e.content.length > 30 ? e.content.substring(0, 30) : e.content, maxLines: 1),
                      selected: state.activeType == 'issue' && state.activeId == e.id,
                      onTap: () => state.setActive('issue', e.id, e.content),
                    ))
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (const bool.fromEnvironment('SHOW_SUBSCRIBE_LINK', defaultValue: true))
                  TextButton(
                    onPressed: () => launchUrl(Uri.parse('https://daybefore.app/#pricing')),
                    child: const Text('Subscribe on website'),
                  ),
                TextButton(
                  onPressed: () {
                    if (auth.isLoggedIn) {
                      auth.logout();
                    } else {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
                    }
                  },
                  child: Text(auth.isLoggedIn ? 'Log Out' : 'Sign In / Sync'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class EditorArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    if (state.activeType == null) {
      return const Center(child: Text('Select an entry from the sidebar, or create a new one.'));
    }

    String title = '';
    if (state.activeType == 'journal') {
      final e = state.journals.firstWhere((e) => e.id == state.activeId, orElse: () => JournalEntry(id:'', content:'', createdAt:0, updatedAt:0));
      if (e.createdAt > 0) {
        final d = DateTime.fromMillisecondsSinceEpoch(e.createdAt);
        title = '\${d.year}-\${d.month.toString().padLeft(2,'0')}-\${d.day.toString().padLeft(2,'0')}_\${d.hour.toString().padLeft(2,'0')}\${d.minute.toString().padLeft(2,'0')}.md';
      }
    } else if (state.activeType == 'core') {
      final e = state.corePoints.firstWhere((e) => e.id == state.activeId, orElse: () => CorePoint(id:'', name:'', content:'', createdAt:0, updatedAt:0));
      title = e.name;
    } else if (state.activeType == 'issue') {
      final e = state.issues.firstWhere((e) => e.id == state.activeId, orElse: () => Issue(id:'', name:'', content:'', isArchived:0, createdAt:0, updatedAt:0));
      title = e.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (state.isSyncing) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: TextEditingController(text: state.draftContent)..selection = TextSelection.fromPosition(TextPosition(offset: state.draftContent.length)),
              maxLines: null,
              expands: true,
              onChanged: (val) => state.updateDraft(val),
              decoration: const InputDecoration(border: InputBorder.none, hintText: 'Start writing...'),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String error = '';
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Day Before', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextField(controller: emailCtrl, decoration: const InputDecoration(hintText: 'Email')),
              const SizedBox(height: 16),
              TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(hintText: 'Passphrase')),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: loading ? null : () async {
                  setState(() { loading = true; error = ''; });
                  try {
                    if (isLogin) {
                      await auth.login(emailCtrl.text.trim(), passCtrl.text);
                    } else {
                      await auth.register(emailCtrl.text.trim(), passCtrl.text);
                    }
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AppShell()));
                  } catch (e) {
                    setState(() => error = e.toString());
                  } finally {
                    setState(() => loading = false);
                  }
                },
                child: Text(isLogin ? 'Log In' : 'Register'),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Don't have an account? Register" : "Already have an account? Log In"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AppShell())),
                child: const Text("Skip & Use Offline"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
`,
  'lib/main.dart': `
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/storage.dart';
import 'core/api.dart';
import 'ui/theme.dart';
import 'ui/app_shell.dart';
import 'features/auth/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final db = LocalDb();
  await db.init();
  
  final api = ApiClient();
  final auth = AuthProvider(api: api);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => AppState(db: db, auth: auth)),
      ],
      child: const DayBeforeApp(),
    )
  );
}

class DayBeforeApp extends StatelessWidget {
  const DayBeforeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Day Before',
      theme: darkTheme,
      home: AppShell(),
    );
  }
}
`,
  'test/crypto_test.dart': `
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:daybefore/core/crypto.dart';

void main() {
  test('hashPassword matches web SHA-256 hex', () async {
    final hash = await DayBeforeCrypto.hashPassword('test');
    expect(hash, '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08');
  });

  test('encrypt then decrypt round-trip', () async {
    final salt = Uint8List.fromList(List.generate(16, (i) => i));
    final key = await DayBeforeCrypto.deriveKey('mypassphrase', salt);
    final original = {'id': 'abc', 'content': 'hello world', 'createdAt': 1234, 'updatedAt': 5678};
    final encrypted = await DayBeforeCrypto.encryptObject(original, key);
    final decrypted = await DayBeforeCrypto.decryptObject(encrypted, key);
    expect(decrypted['content'], 'hello world');
    expect(decrypted['id'], 'abc');
  });

  // Generated via node crypto API simulating Web Crypto AES-GCM
  test('decrypts web-encrypted fixture', () async {
    const webEncrypted = 'AAECAwQFBgcICQoLllMNmmG4Au1HwrigQ6Pr1lCvepJfyovZkmzGj9ki6Ijw8gJIgaVIe59ONDf/rqgxsOGjZr8KMgIWoDnxUeC2Gg1Zuhx76RMdKPdiWtW9e9mXoR2kVw=='; 
    final salt = Uint8List.fromList(List.generate(16, (i) => i));
    final key = await DayBeforeCrypto.deriveKey('testpass', salt);
    final decrypted = await DayBeforeCrypto.decryptObject(webEncrypted, key);
    expect(decrypted['content'], 'cross-platform');
  });
}
`
};

for (const [filename, content] of Object.entries(files)) {
  const fullPath = path.join(projectRoot, filename);
  const dir = path.dirname(fullPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  fs.writeFileSync(fullPath, content);
}
console.log('All files created successfully!');
