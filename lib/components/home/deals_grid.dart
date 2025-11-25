import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';

class DealsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> deals;
  final Function(Map<String, dynamic>) onDealTap;
  final Function(Map<String, dynamic>) onFavoriteToggle;

  const DealsGrid({
    super.key,
    required this.deals,
    required this.onDealTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (deals.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: 50),
          child: Center(
            child: Text("Nenhuma oferta encontrada.",
                style: TextStyle(color: AppColors.chineseWhite)),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildDealCard(deals[index]),
          childCount: deals.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: 0.65, 
        ),
      ),
    );
  }

  Widget _buildDealCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => onDealTap(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(item['img']),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                          Colors.grey, BlendMode.saturation),
                    ),
                  ),
                ),
                
                // Badge de Desconto (Esquerda)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['offer'], 
                      style: const TextStyle(
                        color: Colors.white, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),

                // --- CORAÇÃO SEMPRE BRANCO (Direita) ---
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    onPressed: () => onFavoriteToggle(item),
                    icon: Icon(
                      item['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                      // AQUI ESTAVA O "ERRO": Tirei a condição de cor. Agora é sempre branco.
                      color: Colors.white, 
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          
          Text(
            item['store_name']?.toUpperCase() ?? 'PARCEIRO',
            style: TextStyle(
                color: AppColors.chineseWhite.withOpacity(0.6),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
          const SizedBox(height: 4),
          
          Text(
            item['name'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          
          Row(
            children: [
              Text(
                "R\$ ${item['original_price'].toStringAsFixed(0)}",
                style: TextStyle(
                  color: AppColors.chineseWhite.withOpacity(0.5),
                  fontSize: 12,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              
              Text(
                "R\$ ${item['final_price'].toStringAsFixed(0)}",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}