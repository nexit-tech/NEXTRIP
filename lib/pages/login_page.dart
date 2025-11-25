import 'package:flutter/material.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

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
                  // --- AQUI ESTÁ A LOGO NOVA ---
                  // Certifique-se que o arquivo está em assets/images/
                  Image.asset(
                    'assets/images/logo_branco.png', // <--- NOME DO ARQUIVO QUE VC SUBIU
                    height: 100, // Ajuste a altura se ficar muito grande/pequeno
                    fit: BoxFit.contain,
                  ),
                  
                  const SizedBox(height: 48),

                  // Card de Login
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
                            onPressed: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
                            },
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

                        Row(
                          children: [
                            Expanded(child: _socialButton(icon: FontAwesomeIcons.google, label: 'Google', onTap: () {})),
                            const SizedBox(width: 16),
                            Expanded(child: _socialButton(icon: FontAwesomeIcons.apple, label: 'Apple', onTap: () {})),
                          ],
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
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
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

  Widget _socialButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return OutlinedButton(
      onPressed: onTap,
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