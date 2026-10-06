import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme_provider.dart';
import '../../ui/tokens.dart';
import '../../ui/components/day_button.dart';
import '../../ui/components/day_text_field.dart';
import '../../ui/icons/day_icons.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final palette = PaletteProvider.of(context);
    
    return Scaffold(
      backgroundColor: palette.ground,
      appBar: AppBar(
        backgroundColor: palette.ground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: palette.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DayIcon(name: DayIconName.horizon, size: 28, color: palette.accent),
                const SizedBox(height: 24),
                Text('Sign in', style: Ty.titleLg(palette.text)),
                const SizedBox(height: 24),
                DayTextField(
                  label: 'Email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                DayTextField(
                  label: 'Password',
                  controller: _passwordController,
                  obscure: true,
                  showEyeToggle: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {},
                ),
                const SizedBox(height: 24),
                DayButton(
                  label: 'Sign in',
                  variant: DayButtonVariant.primary,
                  fullWidth: true,
                  loading: false,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Text('Forgot password?', style: Ty.body(palette.accent)),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {},
                  child: Text('Create an account', style: Ty.body(palette.accent)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
