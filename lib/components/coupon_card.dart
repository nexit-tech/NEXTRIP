import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';

class CouponCard extends StatelessWidget {
  final String store;
  final String offer;
  final String code;

  const CouponCard({
    super.key,
    required this.store,
    required this.offer,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Largura fixa pra ficar legal no scroll horizontal
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white, // Contraste total
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                store.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const Icon(FontAwesomeIcons.ticket, color: AppColors.black, size: 16),
            ],
          ),
          
          // Oferta Grande
          Text(
            offer,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),

          // Código tracejado
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("CODE: ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                Text(code, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
              ],
            ),
          )
        ],
      ),
    );
  }
}