import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/auth/auth_provider.dart';
import 'theme_provider.dart';
import 'tokens.dart';
import 'components/day_button.dart';
import 'components/day_text_field.dart';
import 'illustrations/day_illustrations.dart';
import 'components/day_form_error.dart';

class LockScreen extends StatefulWidget {
  final String? redirect;
  const LockScreen({super.key, this.redirect});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  String? _error;
  bool _unlocking = false;

  late final _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late final _shakeAnimation = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: 6), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 6, end: -6), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -6, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

  Future<void> _unlock() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() { _unlocking = true; _error = null; });
    try {
      final auth = context.read<AuthProvider>();
      await auth.unlock(_controller.text);
      if (mounted) {
        final dest = widget.redirect ?? '/';
        context.go(dest);
      }
    } catch (_) {
      setState(() => _error = 'That password did not match.');
      _shakeController.forward(from: 0);
    } finally {
      if (mounted) setState(() => _unlocking = false);
    }
  }

  void _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Your entries remain on this device. You can sign back in any time.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign out')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      context.go('/');
    }
  }

  void _forgotPassword() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Forgot your password?'),
        content: const Text(
          'Day Before uses end-to-end encryption — your password never leaves your device, '
          'so we cannot send a reset email.\n\n'
          'If you have your recovery key, password reset is coming soon.\n\n'
          'Without your recovery key, your encrypted entries cannot be recovered. '
          'You can sign out and start fresh.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    return ColoredBox(
      color: palette.ground,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DayIllustration(name: DayIllustrationName.lockScreen, size: 64),
                    const SizedBox(height: 24),
                    Text('Day Before',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Gelasio', fontSize: 34, height: 40 / 34,
                        fontWeight: FontWeight.w600, color: palette.text)),
                    const SizedBox(height: 12),
                    Text(
                      'Enter your password to open your journal.',
                      textAlign: TextAlign.center,
                      style: Ty.body(palette.muted),
                    ),
                    const SizedBox(height: 32),
                    DayTextField(
                      controller: _controller,
                      label: 'Password',
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _unlock(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      DayFormError(text: _error!),
                    ],
                    const SizedBox(height: 24),
                    DayButton(
                      label: 'Unlock',
                      variant: DayButtonVariant.primary,
                      fullWidth: true,
                      loading: _unlocking,
                      onTap: _unlock,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _forgotPassword,
                          child: Text('Forgot password?', style: Ty.body(palette.muted)),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: _signOut,
                          child: Text('Sign out', style: Ty.body(palette.muted)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
