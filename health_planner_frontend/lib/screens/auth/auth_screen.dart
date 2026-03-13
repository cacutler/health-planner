import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = _isLogin
        ? await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text)
        : await auth.register(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!ok && mounted) {
      // error shown via provider
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) => Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo / brand
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 40,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HEALTH',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3,
                                ),
                              ),
                              Text(
                                'PLANNER',
                                style: TextStyle(
                                  color: AppTheme.accent,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      Text(
                        _isLogin ? 'SIGN IN' : 'CREATE ACCOUNT',
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (auth.error != null) ...[
                        ErrorMessage(auth.error!),
                        const SizedBox(height: 16),
                      ],

                      AppTextField(
                        label: 'Email',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Invalid email'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        label: 'Password',
                        controller: _passwordCtrl,
                        obscure: true,
                        validator: (v) =>
                            v == null || v.length < 6 ? 'Min 6 chars' : null,
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.loading ? null : _submit,
                          child: auth.loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.background,
                                  ),
                                )
                              : Text(_isLogin ? 'SIGN IN' : 'REGISTER'),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          auth.clearError();
                          setState(() => _isLogin = !_isLogin);
                        },
                        child: Text(
                          _isLogin
                              ? "Don't have an account? Register"
                              : 'Already have an account? Sign in',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
