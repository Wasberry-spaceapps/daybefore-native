
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/backup_manager.dart';
import 'core/storage.dart';
import 'core/api.dart';
import 'ui/theme.dart';
import 'ui/app_shell.dart';
import 'features/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'ui/lock_screen.dart';
import 'features/minute/minute_screen.dart';

import 'core/registry.dart';

final _routerKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await registry.init();
  final accountId = await registry.getOrCreateLocalAccount();
  
  final db = LocalDb();
  await db.init(accountId);
  
  final api = ApiClient();
  final auth = AuthProvider(api: api);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => AppState(db: db, auth: auth)),
      ],
      child: DayBeforeApp(accountId: accountId),
    )
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
  late final BackupManager _backupManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _backupManager = BackupManager(
      accountId: widget.accountId,
      exportEncrypted: () async {
        return Uint8List.fromList(utf8.encode('{}')); // Placeholder for actual export
      }
    );
    _backupManager.start();

    // Restore session token on cold start (key will be set after lock-screen unlock)
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
    _backupManager.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _backupManager.writeBackup();
    }
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      final auth = context.read<AuthProvider>();
      if (!auth.isLoggedIn) return; // don't lock if not signed in
      final currentRoute = _router.routerDelegate.currentConfiguration.uri.toString();
      if (!currentRoute.startsWith('/lock') && !currentRoute.startsWith('/auth')) {
        auth.encryptionKey = null; // wipe in-memory key
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
