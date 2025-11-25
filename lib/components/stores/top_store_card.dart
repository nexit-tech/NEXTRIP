import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TopStoreCard extends StatelessWidget {
  final Map<String, dynamic> store;
  final VoidCallback onTap;

  const TopStoreCard({
    super.key,
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260, // Largura fixa pro carrossel
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Gradiente sutil pra destacar
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.eerieBlack, Colors.black],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.nightRider),
        ),
        child: Row(
          children: [
            // Imagem Grande
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(store['img']),
                  fit: BoxFit.cover,
                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tag "TOP"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "DESTAQUE",
                      style: TextStyle(color: AppColors.black, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    store['name'],
                    style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // Estrelas
                  Row(
                    children: List.generate(5, (index) => Icon(
                      index < (store['rating'] ?? 0) ? Icons.star : Icons.star_border,
                      color: AppColors.white,
                      size: 12,
                    )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}