import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import '../theme/app_colors.dart';
import '../components/custom_input.dart';
import '../components/custom_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // --- SNACKBAR PADRÃO (Popupzin) ---
  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.mark_email_read_outlined,
              color: isError ? Colors.redAccent : Colors.green,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Digite seu e-mail.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Envia o e-mail de recuperação
      await _supabase.auth.resetPasswordForEmail(email);

      if (mounted) {
        _showSnackBar("Link enviado! Verifique seu e-mail.");
        
        // Aguarda um pouco e volta para o Login
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) _showSnackBar(e.message, isError: true);
    } catch (e) {
      if (mounted) _showSnackBar("Erro ao enviar e-mail.", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                const Icon(Icons.lock_reset, color: AppColors.white, size: 48),
                const SizedBox(height: 24),
                
                const Text(
                  "Esqueceu a senha?",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Não se preocupe! Digite seu e-mail abaixo e enviaremos um link para você redefinir sua senha.",
                  style: TextStyle(
                    color: AppColors.chineseWhite,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  "Email Cadastrado",
                  style: TextStyle(
                    color: AppColors.chineseWhite,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                CustomInput(
                  controller: _emailController,
                  hint: "seu@email.com",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'ENVIAR LINK DE RECUPERAÇÃO',
                    isLoading: _isLoading,
                    onPressed: _handleResetPassword,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Voltar para o Login",
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}