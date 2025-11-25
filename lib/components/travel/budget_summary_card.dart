import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double totalOriginal;
  final double totalDiscount;
  final double totalFinal;

  const BudgetSummaryCard({
    super.key,
    required this.totalOriginal,
    required this.totalDiscount,
    required this.totalFinal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white, // Card branco para contraste
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          // Linha 1: Preço Cheio
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Subtotal", style: TextStyle(color: Colors.grey)),
              Text(
                "R\$ ${totalOriginal.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.grey, 
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.lineThrough
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Linha 2: Descontos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Descontos Aplicados", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              Text(
                "- R\$ ${totalDiscount.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 12),
          
          // Linha 3: Total a Pagar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL ESTIMADO",
                style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              Text(
                "R\$ ${totalFinal.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}