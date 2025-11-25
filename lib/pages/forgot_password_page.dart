import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleSendEmail() async {
    if (_emailController.text.isEmpty) return;

    setState(() => _isLoading = true);
    
    // Simula envio
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email de recuperação enviado!", style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context); // Volta pro login
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_reset, size: 64, color: AppColors.white),
            const SizedBox(height: 24),
            const Text(
              "Esqueceu a senha?",
              style: TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Não se preocupe. Digite seu email abaixo e enviaremos as instruções para você.",
              style: TextStyle(color: AppColors.chineseWhite, fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            CustomInput(
              controller: _emailController,
              hint: 'seu@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'ENVIAR EMAIL',
                isLoading: _isLoading,
                onPressed: _handleSendEmail,
              ),
            ),
          ],
        ),
      ),
    );
  }
}