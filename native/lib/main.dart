
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
