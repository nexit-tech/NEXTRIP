import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Importante para kIsWeb
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart'; // <--- Importante para a fonte
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import 'home_page.dart';
import 'sign_up_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _supabase = Supabase.instance.client;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIN COM EMAIL E SENHA ---
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preencha e-mail e senha."),
          backgroundColor: Colors.redAccent,
        )
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro inesperado."), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIN COM GOOGLE ---
  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.flutter://login-callback/',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro no login com Google: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- LOGO ESTÁTICO E AJUSTADO ---
                Image.asset(
                  'assets/images/logo_branco.png', 
                  height: 100, // Tamanho ajustado
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.flight_takeoff, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 16),
                
                // --- TEXTO NEXTRIP COM FONTE MONTSERRAT ---
                Text(
                  'NEXTRIP',
                  style: GoogleFonts.montserrat( // <--- FONTE APLICADA AQUI
                    fontSize: 32,
                    fontWeight: FontWeight.w900, // Negrito forte para logo
                    color: AppColors.white,
                    letterSpacing: 4.0, // Espaçamento para estilo
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Planeje sua próxima viagem',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // --- EMAIL ---
                CustomInput(
                  controller: _emailController,
                  hint: 'E-mail',
                  icon: Icons.email_outlined, 
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // --- SENHA ---
                CustomInput(
                  controller: _passwordController,
                  hint: 'Senha',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 10),

                // --- LEMBRAR DE MIM E ESQUECEU A SENHA ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.white,
                          checkColor: AppColors.black,
                          side: const BorderSide(color: Colors.grey),
                          onChanged: (val) => setState(() => _rememberMe = val ?? false),
                        ),
                        const Text(
                          "Lembrar de mim",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                      ),
                      child: const Text(
                        "Esqueceu a senha?",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- BOTÃO ENTRAR ---
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'ENTRAR',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                ),

                const SizedBox(height: 32),

                // --- DIVISOR ---
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.nightRider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Ou continue com",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.nightRider)),
                  ],
                ),

                const SizedBox(height: 24),

                // --- BOTÃO GOOGLE (SOMENTE) ---
                SizedBox(
                  width: double.infinity,
                  child: _socialButton(
                    icon: FontAwesomeIcons.google,
                    label: "Entrar com Google",
                    onPressed: _handleGoogleLogin,
                  ),
                ),

                const SizedBox(height: 40),

                // --- CADASTRE-SE ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Não tem uma conta? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()),
                      ),
                      child: const Text(
                        "Cadastre-se",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.nightRider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.white),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}