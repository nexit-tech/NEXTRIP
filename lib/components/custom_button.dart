import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor; // <--- NOVO CAMPO

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor, // <--- Recebe no construtor
  });

  @override
  Widget build(BuildContext context) {
    // Se for Outlined (botão vazado)
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: Icon(icon ?? Icons.arrow_forward, size: 20),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? AppColors.white,
          // Usa a cor da borda passada ou a padrão
          side: BorderSide(color: borderColor ?? AppColors.nightRider),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // Se for ElevatedButton (botão preenchido)
    final finalBgColor = backgroundColor ?? AppColors.white;
    final finalTextColor = textColor ?? AppColors.black;

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: finalBgColor,
        disabledBackgroundColor: finalBgColor.withOpacity(0.5),
        foregroundColor: finalTextColor,
        padding: const EdgeInsets.symmetric(vertical: 18),
        // Aqui também aplicamos a borda se ela for passada
        side: borderColor != null ? BorderSide(color: borderColor!) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? LoadingAnimationWidget.staggeredDotsWave(
              color: finalTextColor,
              size: 24,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: finalTextColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  text.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
    );
  }
}