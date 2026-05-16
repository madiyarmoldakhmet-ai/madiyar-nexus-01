import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../core/auth_service.dart';
import '../widgets/anime_background.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium login/register screen with gold accents.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegister = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimeBackground(
      assetPath: 'assets/images/hq720.jpg',
      opacity: 0.7,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<AuthService>(
          builder: (context, auth, _) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo — Anime Style
                    Text(
                      'NEXUS',
                      style: GoogleFonts.coveredByYourGrace(
                        fontSize: 64,
                        fontWeight: FontWeight.w900,
                        color: MadiColors.bloodRed,
                        letterSpacing: 6,
                        shadows: [
                          Shadow(
                            color: MadiColors.bloodRed.withValues(alpha: 0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Talent Without Fear',
                      style: GoogleFonts.oswald(
                        color: MadiColors.textMuted,
                        fontSize: 14,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Name field (register only)
                    if (_isRegister) ...[
                      _buildField(
                        controller: _nameController,
                        hint: 'Full Name',
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email
                    _buildField(
                      controller: _emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    _buildField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: MadiColors.textMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),

                    // Error message
                    if (auth.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: MadiColors.rose.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(MadiRadius.md),
                          border: Border.all(
                              color: MadiColors.rose.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: MadiColors.rose, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.errorMessage!,
                                style: const TextStyle(
                                    color: MadiColors.rose, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.state == AuthState.loading
                            ? null
                            : _handleSubmit,
                        child: auth.state == AuthState.loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.black),
                              )
                            : Text(
                                _isRegister ? 'Create Account' : 'Sign In',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Toggle login/register
                    TextButton(
                      onPressed: () =>
                          setState(() => _isRegister = !_isRegister),
                      child: Text(
                        _isRegister
                            ? 'Already have an account? Sign In'
                            : "Don't have an account? Register",
                        style: TextStyle(
                            color: MadiColors.bloodRed,
                            fontWeight: FontWeight.w500),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Demo login shortcut
                    OutlinedButton.icon(
                      onPressed: () {
                        _emailController.text = 'madi@nexus.kz';
                        _passwordController.text = 'madi123';
                        _handleSubmit();
                      },
                      icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                      label: const Text('Quick Demo Login'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: MadiColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: MadiColors.textMuted),
        prefixIcon: Icon(icon, color: MadiColors.textMuted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: MadiColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MadiRadius.md),
          borderSide: const BorderSide(color: MadiColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MadiRadius.md),
          borderSide: const BorderSide(color: MadiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MadiRadius.md),
          borderSide: const BorderSide(color: MadiColors.bloodRed, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  void _handleSubmit() async {
    final auth = context.read<AuthService>();
    if (_isRegister) {
      await auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
    } else {
      await auth.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (mounted && auth.errorMessage == 'ACCOUNT_EXISTS') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Этот аккаунт уже есть, пробуем войти...',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
          backgroundColor: MadiColors.gold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
