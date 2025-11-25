import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StoreGridItem extends StatelessWidget {
  final Map<String, dynamic> store;
  final VoidCallback onTap;

  const StoreGridItem({
    super.key,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.eerieBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.nightRider),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(store['img']),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Nome
            Text(
              store['name'],
              style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // Categoria
            Text(
              store['category'],
              style: const TextStyle(color: AppColors.chineseWhite, fontSize: 12),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // --- ESTRELAS (Rating) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                // Se o index for menor que a nota (ex: 4.5), pinta de branco.
                // Aqui fiz simples: se nota > index, estrela cheia.
                return Icon(
                  index < (store['rating'] ?? 0) ? Icons.star : Icons.star_border,
                  color: AppColors.white, // Estrelas Brancas
                  size: 14,
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}