import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class TravelCard extends StatelessWidget {
  final Map<String, dynamic> travel;

  const TravelCard({super.key, required this.travel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 400, // Card bem alto e imersivo
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(travel['img']),
          fit: BoxFit.cover,
          // Filtro P&B suave, mas deixando ver a imagem
          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
        ),
      ),
      child: Stack(
        children: [
          // Gradiente para o texto aparecer bem
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.6, 1.0],
              ),
            ),
          ),

          // Informações no Rodapé
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Localização e Nota
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        travel['location'].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          travel['rating'].toString(),
                          style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Título Grande
                Text(
                  travel['title'],
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Preço e Dias
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${travel['days']} dias • Voo incluso",
                      style: const TextStyle(color: AppColors.chineseWhite, fontSize: 14),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "A partir de",
                          style: TextStyle(color: AppColors.chineseWhite, fontSize: 10),
                        ),
                        Text(
                          "R\$ ${travel['price']}",
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Botão de Favorito Flutuante
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_border, color: AppColors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}