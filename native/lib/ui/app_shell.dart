
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:go_router/go_router.dart';
import '../core/storage.dart';
import '../core/api.dart';
import '../core/sync.dart';
import '../models/journal_entry.dart';
import '../models/core_point.dart';
import '../models/issue.dart';
import '../features/auth/auth_provider.dart';
import '../features/export/export_service.dart';
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
  final Widget child;
  const AppShell({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 900) {
        return Scaffold(
          body: Row(
            children: [
              SizedBox(width: 320, child: Sidebar()),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      } else if (constraints.maxWidth >= 600) {
        return Scaffold(
          body: Row(
            children: [
              SizedBox(width: 240, child: Sidebar()),
              const VerticalDivider(width: 1),
              Expanded(child: child),
            ],
          ),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Day Before'),
          ),
          drawer: Drawer(child: Sidebar()),
          body: child,
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
                      title: Text('${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')} ${d.hour.toString().padLeft(2,'0')}${d.minute.toString().padLeft(2,'0')}'),
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
                TextButton(
                  onPressed: () => context.go('/minute'),
                  child: const Text('Take a minute'),
                ),
                TextButton(
                  onPressed: () => ExportService.exportToPdf(state.journals, state.corePoints, state.issues),
                  child: const Text('Export to PDF'),
                ),
                TextButton(
                  onPressed: () => ExportService.exportToZip(state.journals, state.corePoints, state.issues),
                  child: const Text('Export to ZIP'),
                ),
                if (const bool.fromEnvironment('SHOW_SUBSCRIBE_LINK', defaultValue: true))
                  TextButton(
                    onPressed: () => launchUrl(Uri.parse('https://daybefore.app/#pricing')),
                    child: const Text('Subscribe on website'),
                  ),
                TextButton(
                  onPressed: () {
                    if (auth.isLoggedIn) {
                      auth.logout();
                      context.go('/auth');
                    } else {
                      context.go('/auth');
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
        title = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}_${d.hour.toString().padLeft(2,'0')}${d.minute.toString().padLeft(2,'0')}.md';
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
  String? recoveryKey;
  bool isMigration = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    if (recoveryKey != null) {
      return Scaffold(
        body: Center(
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isMigration ? 'Account Upgraded' : 'Save Your Recovery Key',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  isMigration
                    ? 'Your account has been upgraded to stronger encryption. '
                      'This key is the ONLY way to recover your journal if you forget your password. '
                      'This screen appears once — save it now.'
                    : 'This is the ONLY way to recover your journal if you forget your password. '
                      'We cannot reset it for you. Write it down or save it somewhere safe.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    recoveryKey!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 16, letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() => recoveryKey = null);
                    context.go('/');
                  },
                  child: const Text('I have saved it'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                      final migrationKey = await auth.login(emailCtrl.text.trim(), passCtrl.text);
                      if (mounted) {
                        if (migrationKey != null) {
                          setState(() { recoveryKey = migrationKey; isMigration = true; });
                        } else {
                          context.go('/');
                        }
                      }
                    } else {
                      final regKey = await auth.register(emailCtrl.text.trim(), passCtrl.text);
                      if (mounted) setState(() { recoveryKey = regKey; isMigration = false; });
                    }
                  } catch (e) {
                    setState(() => error = e.toString());
                  } finally {
                    if (mounted) setState(() => loading = false);
                  }
                },
                child: Text(isLogin ? 'Log In' : 'Register'),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? "Don't have an account? Register" : "Already have an account? Log In"),
              ),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text("Skip & Use Offline"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
