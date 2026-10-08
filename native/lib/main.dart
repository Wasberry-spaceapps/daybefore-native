
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/backup_format.dart' show createBackup;
import 'core/backup_manager.dart';
import 'core/storage.dart';
import 'core/api.dart';
import 'ui/theme.dart';
import 'ui/app_shell.dart';
import 'features/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'ui/lock_screen.dart';
import 'features/minute/minute_screen.dart';
import 'features/account/account_screen.dart';
import 'features/account/plan_screen.dart';
import 'features/account/sign_in_screen.dart';
import 'features/account/switch_account_screen.dart';
import 'features/export/export_screen.dart';

import 'core/registry.dart';

final _routerKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await registry.init();
  final accountId = await registry.getOrCreateLocalAccount();

  final db = LocalDb();
  try {
    await db.init(accountId);
  } catch (e) {
    if (e.toString().contains('DATABASE_CORRUPT')) {
      // handled inside LocalDb.init — db renamed, let app start with empty state
    } else {
      rethrow;
    }
  }

  final api = ApiClient();
  final auth = AuthProvider(api: api);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => AppState(db: db, auth: auth)),
        ChangeNotifierProvider(
          create: (_) {
            final bm = BackupManager(
              accountId: accountId,
              exportEncrypted: () async {
                final key = auth.encryptionKey;
                if (key == null) return Uint8List(0);
                final allData = await db.exportAll();
                return await createBackup(accountId, key, allData);
              },
            );
            bm.start();
            return bm;
          },
        ),
      ],
      child: DayBeforeApp(accountId: accountId),
    ),
  );
}

class DayBeforeApp extends StatefulWidget {
  final String accountId;
  const DayBeforeApp({Key? key, required this.accountId}) : super(key: key);
  @override
  State<DayBeforeApp> createState() => _DayBeforeAppState();
}

class _DayBeforeAppState extends State<DayBeforeApp> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Restore session token on cold start (key is set after lock-screen unlock)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.tryRestoreSession();
      if (mounted && auth.isLoggedIn) {
        _router.go('/lock');
      }
    });

    _router = GoRouter(
      navigatorKey: _routerKey,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/auth',
          builder: (context, state) => const AuthScreen(),
        ),
        GoRoute(
          path: '/lock',
          builder: (context, state) => LockScreen(
            redirect: state.uri.queryParameters['redirect'],
          ),
        ),
        GoRoute(
          path: '/minute',
          builder: (context, state) => const MinuteScreen(),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountScreen(),
        ),
        GoRoute(
          path: '/plan',
          builder: (context, state) => const PlanScreen(),
        ),
        GoRoute(
          path: '/sign-in',
          builder: (context, state) => const SignInScreen(),
        ),
        GoRoute(
          path: '/switch-account',
          builder: (context, state) => const SwitchAccountScreen(),
        ),
        GoRoute(
          path: '/export',
          builder: (context, state) => const ExportScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => EditorArea(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bm = context.read<BackupManager>();
    if (state == AppLifecycleState.paused) {
      bm.writeBackup();
    }
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      final auth = context.read<AuthProvider>();
      if (!auth.isLoggedIn) return;
      final currentRoute = _router.routerDelegate.currentConfiguration.uri.toString();
      if (!currentRoute.startsWith('/lock') && !currentRoute.startsWith('/auth')) {
        auth.encryptionKey = null;
        _router.go('/lock?redirect=${Uri.encodeComponent(currentRoute)}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Day Before',
      theme: darkTheme,
      routerConfig: _router,
    );
  }
}
