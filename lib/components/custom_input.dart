import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- Importante para os Formatters
import '../theme/app_colors.dart';

class CustomInput extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters; // <--- NOVO: Lista de regras

  const CustomInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters, // <--- Recebe no construtor
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.eerieBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.nightRider),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        keyboardType: widget.keyboardType,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        inputFormatters: widget.inputFormatters, // <--- APLICA AQUI
        style: const TextStyle(color: AppColors.white),
        cursorColor: AppColors.white,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: AppColors.chineseWhite.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(widget.icon, color: AppColors.chineseWhite, size: 20),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.chineseWhite,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }
}