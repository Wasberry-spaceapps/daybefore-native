
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/storage.dart';
import 'core/api.dart';
import 'ui/theme.dart';
import 'ui/app_shell.dart';
import 'features/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'ui/lock_screen.dart';
import 'features/minute/minute_screen.dart';

final _routerKey = GlobalKey<NavigatorState>();

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

class DayBeforeApp extends StatefulWidget {
  const DayBeforeApp({Key? key}) : super(key: key);
  @override
  State<DayBeforeApp> createState() => _DayBeforeAppState();
}

class _DayBeforeAppState extends State<DayBeforeApp> with WidgetsBindingObserver {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      final currentRoute = _router.routerDelegate.currentConfiguration.uri.toString();
      if (!currentRoute.startsWith('/lock') && !currentRoute.startsWith('/auth')) {
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
