import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double totalCost;
  final double totalSavings;

  const BudgetSummaryCard({
    super.key,
    required this.totalCost,
    required this.totalSavings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white, // Destaque Branco
        borderRadius: BorderRadius.circular(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Custo Estimado", style: TextStyle(color: AppColors.black)),
              Text(
                "R\$ ${totalCost.toStringAsFixed(2)}",
                style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.grey),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "ECONOMIA VIP",
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
              Text(
                "R\$ ${totalSavings.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}