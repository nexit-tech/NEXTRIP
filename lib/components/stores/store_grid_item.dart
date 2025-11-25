import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class StoreGridItem extends StatelessWidget {
  final Map<String, dynamic> store;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle; // <--- NOVO CALLBACK
  final bool isFavorite; // <--- ESTADO DO FAVORITO

  const StoreGridItem({
    super.key,
    required this.store,
    required this.onTap,
    required this.onFavoriteToggle, // <--- EXIGIDO
    required this.isFavorite, // <--- EXIGIDO
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // O Card Original
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.eerieBlack,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.nightRider),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50, width: 50,
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
                Text(
                  store['name'],
                  style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  store['category'] ?? '',
                  style: const TextStyle(color: AppColors.chineseWhite, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < (store['rating'] ?? 0) ? Icons.star : Icons.star_border,
                      color: AppColors.white,
                      size: 14,
                    );
                  }),
                )
              ],
            ),
          ),

          // Botão de Coração (Posicionado no canto superior direito)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3), // Fundo semi-transparente
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white, // Sempre branco no estilo monocromático
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}