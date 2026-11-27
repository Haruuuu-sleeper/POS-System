import 'package:material_ui/material_ui.dart';

import '../pos_store.dart';
import '../pos_theme.dart';

class AuthScreen extends StatefulWidget {
  final PosStore store;
  final VoidCallback? onAuthenticated;

  const AuthScreen({super.key, required this.store, this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final fullName = _nameController.text.trim();

      final error = _isLogin
          ? widget.store.signIn(email, password)
          : widget.store.signUp(
              fullName: fullName,
              email: email,
              password: password,
              role: UserRole.cashier,
            );

      if (error != null) {
        setState(() => _errorMessage = error);
        return;
      }

      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();

      widget.onAuthenticated?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Authentication failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.1,
            colors: [Color(0xFF13294B), PosColors.abyssBlack],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: PosColors.elevatedCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PosColors.borderSubtle),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x88000000),
                        blurRadius: 32,
                        offset: Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  PosColors.electricBlue,
                                  PosColors.cobaltGlow,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x553B82F6),
                                  blurRadius: 18,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.point_of_sale_rounded,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _isLogin ? 'Welcome Back' : 'Create Staff Account',
                          textAlign: TextAlign.center,
                          style: PosTypography.display(context, size: 24),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isLogin
                              ? 'Demo Admin: admin@pos.local  •  password123'
                              : 'Register a cashier account to access the register',
                          textAlign: TextAlign.center,
                          style: PosTypography.body(
                            context,
                            size: 13,
                            color: PosColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (_isLogin) return null;
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!trimmed.contains('@') ||
                                !trimmed.contains('.')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Show password'
                                  : 'Hide password',
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: PosColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: PosColors.danger.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: PosColors.danger.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: PosTypography.body(
                                context,
                                size: 12.5,
                                color: PosColors.danger,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _submit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Sign In' : 'Create Account',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _isSubmitting ? null : _toggleMode,
                          style: TextButton.styleFrom(
                            foregroundColor: PosColors.skyPulse,
                          ),
                          child: Text(
                            _isLogin
                                ? "Don't have an account? Sign Up"
                                : 'Already have an account? Sign In',
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
      ),
    );
  }
}
