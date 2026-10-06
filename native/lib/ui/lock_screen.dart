import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LockScreen extends StatefulWidget {
  final String? redirect;
  const LockScreen({Key? key, this.redirect}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 64),
              const SizedBox(height: 16),
              const Text('App Locked', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Passphrase'),
                onSubmitted: (_) => _unlock(auth),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : () => _unlock(auth),
                child: const Text('Unlock'),
              ),
              TextButton(
                onPressed: () {
                  auth.logout();
                  context.go('/auth');
                },
                child: const Text('Log Out'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _unlock(AuthProvider auth) async {
    setState(() { _loading = true; _error = ''; });
    try {
      final success = await auth.verifyPassword(_passCtrl.text);
      if (success) {
        if (widget.redirect != null) {
          context.go(widget.redirect!);
        } else {
          context.go('/');
        }
      } else {
        setState(() => _error = 'Incorrect passphrase');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
