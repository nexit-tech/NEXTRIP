import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';
import 'home_page.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _supabase = Supabase.instance.client;
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.white,
        content: Text(msg, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updatePassword() async {
    if (_passwordController.text != _confirmController.text) {
      _showSnackBar("As senhas não coincidem.", isError: true);
      return;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar("Senha muito curta.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Atualiza a senha do usuário LOGADO (o link do email já logou ele)
      final UserResponse res = await _supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      if (res.user != null) {
        if (mounted) {
          _showSnackBar("Senha atualizada com sucesso!");
          await Future.delayed(const Duration(seconds: 1));
          // Vai para a Home
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      _showSnackBar("Erro ao atualizar senha.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(backgroundColor: AppColors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Nova Senha", style: TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Digite sua nova senha abaixo.", style: TextStyle(color: AppColors.chineseWhite)),
            
            const SizedBox(height: 32),
            CustomInput(controller: _passwordController, hint: "Nova Senha", icon: Icons.lock_outline, isPassword: true),
            const SizedBox(height: 16),
            CustomInput(controller: _confirmController, hint: "Confirmar Senha", icon: Icons.lock, isPassword: true),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(text: 'ATUALIZAR SENHA', isLoading: _isLoading, onPressed: _updatePassword),
            ),
          ],
        ),
      ),
    );
  }
}