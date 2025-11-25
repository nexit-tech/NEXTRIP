import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  // CPF REMOVIDO
  final _dateController = TextEditingController();
  
  // Senhas
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // Estado da Força da Senha
  double _passwordStrength = 0;
  String _strengthText = "";
  Color _strengthColor = AppColors.nightRider;

  void _updatePasswordStrength(String value) {
    double strength = 0;
    String text = "";
    Color color = AppColors.nightRider;

    if (value.isEmpty) {
      strength = 0; text = "";
    } else if (value.length < 6) {
      strength = 0.25; text = "Muito Fraca"; color = Colors.redAccent;
    } else if (value.length < 8) {
      strength = 0.5; text = "Fraca"; color = Colors.orangeAccent;
    } else {
      bool hasLetters = value.contains(RegExp(r'[a-zA-Z]'));
      bool hasDigits = value.contains(RegExp(r'[0-9]'));
      
      if (hasLetters && hasDigits && value.length >= 8) {
        strength = 1.0; text = "Forte"; color = Colors.greenAccent;
      } else {
        strength = 0.75; text = "Média"; color = Colors.yellowAccent;
      }
    }

    setState(() {
      _passwordStrength = strength;
      _strengthText = text;
      _strengthColor = color;
    });
  }

  void _handleSignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("As senhas não coincidem!", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white));
      return;
    }

    if (_passwordStrength < 0.5) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A senha é muito fraca.", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Criar Conta", style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Preencha seus dados para começar.", style: TextStyle(color: AppColors.chineseWhite, fontSize: 14)),
                
                const SizedBox(height: 32),

                _label("Nome Completo"),
                CustomInput(controller: _nameController, hint: "Ex: Gabriel Dev", icon: Icons.person_outline),
                const SizedBox(height: 16),

                _label("Email"),
                CustomInput(controller: _emailController, hint: "seu@email.com", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Telefone"),
                          CustomInput(
                            controller: _phoneController, 
                            hint: "(11) 99999-9999", 
                            icon: Icons.phone_outlined, 
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly, PhoneInputFormatter(), LengthLimitingTextInputFormatter(15)],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Nascimento"),
                          // --- DATA AGORA É DIGITÁVEL ---
                          CustomInput(
                            controller: _dateController, 
                            hint: "DD/MM/AAAA", 
                            icon: Icons.calendar_today,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly, 
                              DateInputFormatter(), // Formata sozinho
                              LengthLimitingTextInputFormatter(10) // DD/MM/AAAA
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // CPF REMOVIDO DAQUI

                const SizedBox(height: 16),

                _label("Senha"),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.eerieBlack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.nightRider),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: _updatePasswordStrength,
                    style: const TextStyle(color: AppColors.white),
                    cursorColor: AppColors.white,
                    decoration: InputDecoration(
                      hintText: "••••••••",
                      hintStyle: TextStyle(color: AppColors.chineseWhite.withOpacity(0.5), fontSize: 14),
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.chineseWhite, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                  ),
                ),

                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: AppColors.nightRider,
                          color: _strengthColor,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(_strengthText, style: TextStyle(color: _strengthColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                _label("Confirmar Senha"),
                CustomInput(controller: _confirmPasswordController, hint: "••••••••", icon: Icons.lock_reset, isPassword: true),

                const SizedBox(height: 40),

                SizedBox(width: double.infinity, child: CustomButton(text: 'CADASTRAR', isLoading: _isLoading, onPressed: _handleSignUp)),
                
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Já tem uma conta? ", style: TextStyle(color: AppColors.chineseWhite)),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.pop(context), 
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: const Text("Entrar", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold))
                      )
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

// --- FORMATADORES ---

class PhoneInputFormatter extends TextInputFormatter {
  @override TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var t = n.text; if (t.isEmpty) return n; var b = StringBuffer();
    for (int i = 0; i < t.length; i++) { if (i==0) b.write('('); if (i==2) b.write(') '); if (i==7) b.write('-'); b.write(t[i]); }
    return n.copyWith(text: b.toString(), selection: TextSelection.collapsed(offset: b.length));
  }
}

// FORMATADOR DE DATA (DD/MM/AAAA)
class DateInputFormatter extends TextInputFormatter {
  @override TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    var t = n.text; if (t.isEmpty) return n; var b = StringBuffer();
    for (int i = 0; i < t.length; i++) { 
      if (i==2 || i==4) b.write('/'); // Adiciona barra
      b.write(t[i]); 
    }
    return n.copyWith(text: b.toString(), selection: TextSelection.collapsed(offset: b.length));
  }
}