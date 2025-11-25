import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomSearchBar extends StatelessWidget {
  final Function(String) onChanged;
  final VoidCallback onFilterTap;
  final String? hintText; // <--- NOVO: Texto opcional

  const CustomSearchBar({
    super.key,
    required this.onChanged,
    required this.onFilterTap,
    this.hintText, // <--- Recebe no construtor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, 
      decoration: BoxDecoration(
        color: AppColors.eerieBlack,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.nightRider),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(Icons.search, color: AppColors.white, size: 22),
          ),
          
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
              cursorColor: AppColors.white,
              decoration: InputDecoration(
                // USA O TEXTO NOVO OU O PADRÃO
                hintText: hintText ?? 'Buscar promoções',
                hintStyle: const TextStyle(
                  color: AppColors.chineseWhite,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                isDense: true,
              ),
            ),
          ),

          Container(
            width: 1,
            height: 24,
            color: AppColors.nightRider,
          ),

          IconButton(
            onPressed: onFilterTap,
            icon: const Icon(Icons.tune_rounded, color: AppColors.white, size: 22),
            splashRadius: 20,
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}