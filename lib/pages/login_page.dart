import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_v7_web/theme/app_colors.dart';
import 'package:app_v7_web/components/custom_input.dart';
import 'package:app_v7_web/components/custom_button.dart';
import 'package:app_v7_web/pages/home_page.dart';
import 'package:app_v7_web/pages/sign_up_page.dart';
import 'package:app_v7_web/pages/forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preencha e-mail e senha.")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // --- CORREÇÃO AQUI: NAVEGAÇÃO EXPLÍCITA ---
      if (res.user != null && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
        );
      }
      // ------------------------------------------
      
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro inesperado."), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HANDLER PARA LOGIN SOCIAL ---
  Future<void> _handleSocialLogin(OAuthProvider provider) async {
    // Implementamos apenas o Google por enquanto
    if (provider != OAuthProvider.google) return; 
    
    setState(() => _isLoading = true);
    
    final String? redirectToUrl = kIsWeb ? null : 'io.supabase.flutter://login-callback';

    try {
      await _supabase.auth.signInWithOAuth(
        provider,
        redirectTo: redirectToUrl,
      );
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao logar com Google. Verifique a configuração."), backgroundColor: Colors.redAccent)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Falha na autenticação social."), backgroundColor: Colors.redAccent)
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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo_branco.png', 
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  
                  const SizedBox(height: 48),

                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.eerieBlack,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.nightRider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Email", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        CustomInput(controller: _emailController, hint: 'seu@email.com', icon: Icons.email_outlined),

                        const SizedBox(height: 20),

                        const Text("Senha", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        CustomInput(controller: _passwordController, hint: '••••••••', icon: Icons.lock_outline, isPassword: true),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            SizedBox(
                              height: 24, width: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.white,
                                checkColor: AppColors.black,
                                side: const BorderSide(color: AppColors.chineseWhite),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (val) => setState(() => _rememberMe = val ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Lembrar de mim', style: TextStyle(color: AppColors.chineseWhite, fontSize: 12)),
                            const Spacer(),
                            
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordPage()));
                              },
                              child: const Text('Esqueceu a senha?', style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            text: 'ENTRAR',
                            isLoading: _isLoading,
                            onPressed: _handleLogin,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: const [
                            Expanded(child: Divider(color: AppColors.nightRider)),
                            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Ou', style: TextStyle(color: AppColors.chineseWhite, fontSize: 12))),
                            Expanded(child: Divider(color: AppColors.nightRider)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: _socialButton(
                            icon: FontAwesomeIcons.google, 
                            label: 'Google', 
                            onPressed: () => _handleSocialLogin(OAuthProvider.google)
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Não tem uma conta? ', style: TextStyle(color: AppColors.chineseWhite)),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(builder: (context) => const SignUpPage())
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Cadastre-se',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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