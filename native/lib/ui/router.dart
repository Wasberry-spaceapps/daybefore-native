import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/journal/home_screen.dart';
import '../features/journal/entry_editor_screen.dart';
import '../features/issues/issue_detail_screen.dart';
import '../features/core_points/core_points_screen.dart';
import '../features/account/account_screen.dart';
import '../features/account/plan_screen.dart';
import '../features/account/sign_in_screen.dart';
import 'lock_screen.dart';
import '../features/minute/minute_screen.dart';
import '../features/export/export_screen.dart';
import 'shell/app_shell.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Assuming lockProvider exists, placeholder logic:
    // final locked = context.read<LockProvider>().isLocked;
    // if (locked && state.matchedLocation != '/lock') return '/lock';
    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: '/entry/:id',
          name: 'entry',
          builder: (_, state) => EntryEditorScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/issue/:id',
          name: 'issue',
          builder: (_, state) => IssueDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/core/:id',
          name: 'core',
          builder: (_, state) => CorePointScreen(id: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: '/account',
      name: 'account',
      builder: (_, __) => const AccountScreen(),
    ),
    GoRoute(
      path: '/plan',
      name: 'plan',
      builder: (_, __) => const PlanScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      name: 'sign-in',
      builder: (_, __) => const SignInScreen(),
    ),
    GoRoute(
      path: '/lock',
      name: 'lock',
      pageBuilder: (context, state) => const NoTransitionPage(child: LockScreen()),
    ),
    GoRoute(
      path: '/minute',
      name: 'minute',
      builder: (_, __) => const MinuteScreen(),
    ),
    GoRoute(
      path: '/export',
      name: 'export',
      builder: (_, __) => const ExportScreen(),
    ),
    GoRoute(
      path: '/student',
      name: 'student',
      builder: (_, __) => const Scaffold(body: Center(child: Text('Student Screen'))), // Placeholder
    ),
  ],
);
