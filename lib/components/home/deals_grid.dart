import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';

class DealsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> deals;
  final Function(Map<String, dynamic>) onDealTap;

  const DealsGrid({
    super.key,
    required this.deals,
    required this.onDealTap,
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
          childAspectRatio: 0.72,
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
                if (item['isFavorite'])
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: AppColors.black,
                      radius: 12,
                      child: Icon(Icons.favorite, color: Color.fromARGB(255, 255, 255, 255), size: 14),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(item['name'],
              style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(FontAwesomeIcons.tag, size: 12, color: AppColors.white),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['offer'],
                        style: const TextStyle(
                            color: AppColors.chineseWhite, fontSize: 12)),
                    
                    // --- CORREÇÃO AQUI: SÓ MOSTRA SE TIVER DISTÂNCIA ---
                    if (item['distance'] != null) 
                      Text(item['distance'],
                          style: TextStyle(
                              color: AppColors.chineseWhite.withOpacity(0.7),
                              fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}