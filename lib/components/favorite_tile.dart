import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FavoriteTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap; // <--- NOVO: Função de clique opcional

  const FavoriteTile({
    super.key,
    required this.item,
    this.onTap, // <--- Recebe no construtor
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // <--- Liga o gesto
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.eerieBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.nightRider),
        ),
        child: Row(
          children: [
            // Imagem Pequena
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item['img'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                colorBlendMode: BlendMode.saturation,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            
            // Textos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['category'] ?? item['offer'] ?? '', // Tenta pegar categoria ou oferta
                    style: const TextStyle(
                      color: AppColors.chineseWhite,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Ícone de seta pra indicar que é clicável (opcional, mas ajuda na UX)
            const Icon(Icons.chevron_right, color: AppColors.nightRider),
          ],
        ),
      ),
    );
  }
}