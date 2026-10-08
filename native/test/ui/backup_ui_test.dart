import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:daybefore/core/api.dart';
import 'package:daybefore/core/backup_manager.dart';
import 'package:daybefore/core/registry.dart';
import 'package:daybefore/core/storage.dart';
import 'package:daybefore/features/auth/auth_provider.dart';
import 'package:daybefore/features/account/account_screen.dart';
import 'package:daybefore/features/account/switch_account_screen.dart';
import 'package:daybefore/ui/app_shell.dart' show AppState;
import 'package:daybefore/ui/theme.dart';
import 'package:daybefore/ui/theme_provider.dart';
import 'package:daybefore/ui/tokens.dart';

// ─── Fakes ───────────────────────────────────────────────────────────────────

class _FakeLocalDb extends LocalDb {
  final int fakeCount;
  _FakeLocalDb({this.fakeCount = 3});

  @override
  Future<void> init(String accountId) async {}

  @override
  Future<int> entryCount() async => fakeCount;

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<List<Map<String, dynamic>>> getAll(String table,
          {String orderBy = 'createdAt DESC'}) async =>
      [];

  @override
  Future<Map<String, dynamic>?> getById(String table, String id) async => null;

  @override
  Future<void> upsert(String table, Map<String, dynamic> row) async {}

  @override
  Future<void> delete(String table, String id) async {}

  @override
  Future<Map<String, dynamic>> exportAll() async => {'version': 1};
}

class _FakeAuth extends AuthProvider {
  final bool fakeLoggedIn;
  final String? fakeEmail;

  _FakeAuth({this.fakeLoggedIn = false, this.fakeEmail}) : super(api: ApiClient()) {
    email = fakeEmail;
    if (fakeLoggedIn) token = 'fake-token';
  }

  @override
  bool get isLoggedIn => fakeLoggedIn;

  @override
  Future<void> logout() async {
    token = null;
    email = null;
    notifyListeners();
  }
}

class _FakeBackupManager extends BackupManager {
  int _fakeLastBackup;
  bool _fakeBacking;

  _FakeBackupManager({int lastBackup = 0, bool backing = false})
      : _fakeLastBackup = lastBackup,
        _fakeBacking = backing,
        super(
          accountId: 'test-account',
          exportEncrypted: () async => Uint8List(0),
        );

  @override
  int get lastBackupTime => _fakeLastBackup;

  @override
  bool get isBackingUp => _fakeBacking;

  @override
  bool get hasBackup => _fakeLastBackup > 0;

  @override
  void start() {} // no timer

  @override
  Future<void> writeBackup() async {
    _fakeLastBackup = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
  }

  @override
  Future<List<BackupInfo>> listBackups() async => [];
}

class _FakeAppState extends AppState {
  _FakeAppState(_FakeLocalDb db, _FakeAuth auth) : super(db: db, auth: auth);

  @override
  Future<void> loadAll() async {} // no-op — no real db
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _buildApp(
  Widget screen, {
  _FakeAuth? auth,
  _FakeBackupManager? bm,
  _FakeAppState? state,
  List<GoRoute> extraRoutes = const [],
}) {
  final fakeAuth = auth ?? _FakeAuth();
  final fakeDb = _FakeLocalDb();
  final fakeBm = bm ?? _FakeBackupManager();
  final fakeState = state ?? _FakeAppState(fakeDb, fakeAuth);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => screen),
      GoRoute(path: '/export', builder: (_, __) => const _Stub('Export')),
      GoRoute(path: '/sign-in', builder: (_, __) => const _Stub('Sign in')),
      GoRoute(path: '/switch-account', builder: (_, __) => const SwitchAccountScreen()),
      GoRoute(path: '/plan', builder: (_, __) => const _Stub('Plan')),
      ...extraRoutes,
    ],
  );

  return PaletteProvider(
    palette: Palette.night,
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: fakeAuth),
        ChangeNotifierProvider<BackupManager>.value(value: fakeBm),
        ChangeNotifierProvider<AppState>.value(value: fakeState),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: darkTheme,
      ),
    ),
  );
}

class _Stub extends StatelessWidget {
  final String label;
  const _Stub(this.label);
  @override
  Widget build(BuildContext context) => Scaffold(body: Text(label));
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});

    // Provide a real temp dir so path_provider works without a host app
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall call) async => Directory.systemTemp.path,
    );

    await registry.init();
  });
  // 1 ─ Backup section shows expected labels
  testWidgets(
    'Account screen shows backup section with Auto-backup and last backup labels',
    (tester) async {
      final bm = _FakeBackupManager(
        lastBackup: DateTime.now().millisecondsSinceEpoch - 60000 * 5,
      );
      await tester.pumpWidget(_buildApp(const AccountScreen(), bm: bm));
      await tester.pumpAndSettle();

      expect(find.text('Backup'), findsOneWidget);
      expect(find.text('Auto-backup'), findsOneWidget);
      expect(find.text('Last backup'), findsOneWidget);
      expect(find.text('Back up now'), findsOneWidget);
    },
  );

  // 2 ─ "Back up now" triggers backup and shows toast
  testWidgets(
    'Tapping "Back up now" calls writeBackup',
    (tester) async {
      final bm = _FakeBackupManager();
      final initialTime = bm.lastBackupTime;

      await tester.pumpWidget(_buildApp(const AccountScreen(), bm: bm));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back up now'));
      await tester.pump();

      expect(bm.lastBackupTime, greaterThan(initialTime));

      // drain the DayToast 3-second timer so no pending timers remain
      await tester.pump(const Duration(seconds: 4));
    },
  );

  // 3 ─ Switch account screen lists accounts header
  testWidgets(
    'Switch account screen renders "Our journals on this device" heading',
    (tester) async {
      await tester.pumpWidget(_buildApp(const SwitchAccountScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Our journals on this device'), findsOneWidget);
      expect(find.text('Add another account'), findsOneWidget);
      expect(find.text('Start a new local journal'), findsOneWidget);
    },
  );

  // 4 ─ Tapping "Add another account" navigates to /sign-in
  testWidgets(
    'Tapping "Add another account" navigates to sign-in screen',
    (tester) async {
      await tester.pumpWidget(_buildApp(const SwitchAccountScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add another account'));
      await tester.pumpAndSettle();

      expect(find.text('Sign in'), findsOneWidget);
    },
  );

  // 5 ─ Delete account countdown: starts at 30, confirm becomes active at 0
  testWidgets(
    'Delete account dialog counts down 30 seconds then enables confirm',
    (tester) async {
      final fakeDb = _FakeLocalDb(fakeCount: 7);
      final fakeAuth = _FakeAuth();
      final fakeState = _FakeAppState(fakeDb, fakeAuth);
      final fakeBm = _FakeBackupManager();

      await tester.pumpWidget(_buildApp(
        const AccountScreen(),
        auth: fakeAuth,
        bm: fakeBm,
        state: fakeState,
      ));
      await tester.pumpAndSettle();

      // Scroll "Delete account" into view and open the dialog
      await tester.ensureVisible(find.text('Delete account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();

      // Entry count shown
      expect(find.textContaining('7 entries'), findsOneWidget);

      // Tap "Delete everything" to start countdown
      await tester.tap(find.text('Delete everything'));
      await tester.pump();

      // "Deleting in 30 seconds…" visible, confirm not yet active
      expect(find.text('Confirm delete'), findsNothing);
      expect(find.textContaining('Deleting in'), findsOneWidget);

      // Advance 30 seconds (fires all 30 timer ticks)
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pump();

      // "Confirm delete" button now enabled
      expect(find.text('Confirm delete'), findsOneWidget);
    },
  );

  // 6 ─ Sign out shows "entries remain on this device" text
  testWidgets(
    'Sign out dialog contains "entries remain on this device"',
    (tester) async {
      final fakeAuth = _FakeAuth(fakeLoggedIn: true, fakeEmail: 'me@test.com');
      await tester.pumpWidget(_buildApp(const AccountScreen(), auth: fakeAuth));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sign out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.textContaining('entries remain on this device'), findsOneWidget);
    },
  );
}
