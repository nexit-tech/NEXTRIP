import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SavingsCard extends StatelessWidget {
  final double amount;

  const SavingsCard({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.eerieBlack,
            AppColors.black,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.nightRider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.savings_outlined, color: AppColors.chineseWhite, size: 20),
              SizedBox(width: 12),
              Text(
                "VOCÊ JÁ ECONOMIZOU",
                style: TextStyle(
                  color: AppColors.chineseWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "R\$ ${amount.toStringAsFixed(2).replaceAll('.', ',')}",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          
          // --- CORREÇÃO DE LEGIBILIDADE AQUI ---
          const Text(
            "Baseado em 5 cupons resgatados.",
            style: TextStyle(
              color: AppColors.chineseWhite, // <--- Mudei pra ficar legível
              fontSize: 12,
              fontWeight: FontWeight.w300
            ),
          ),
        ],
      ),
    );
  }
}