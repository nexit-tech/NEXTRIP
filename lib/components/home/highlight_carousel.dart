import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../theme/app_colors.dart';

class HighlightCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> highlights;
  final Function(Map<String, dynamic>) onHighlightTap;
  final Function(Map<String, dynamic>) onFavoriteToggle; // <--- NOVO

  const HighlightCarousel({
    super.key,
    required this.highlights,
    required this.onHighlightTap,
    required this.onFavoriteToggle, // <--- NOVO
  });

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) return const SizedBox.shrink();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.85,
          ),
          items: highlights.map((highlight) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () => onHighlightTap(highlight),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(highlight['img']),
                        fit: BoxFit.cover,
                        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Gradiente
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                            ),
                          ),
                        ),
                        
                        // --- CORAÇÃO (Direita) ---
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => onFavoriteToggle(highlight),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                highlight['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                                color: highlight['isFavorite'] ? const Color.fromARGB(255, 255, 255, 255) : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                        // Conteúdo
                        Positioned(
                          bottom: 20, left: 20, right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                                child: Text(highlight['offer'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(height: 8),
                              Text(highlight['store_name']?.toUpperCase() ?? 'PARCEIRO', style: TextStyle(color: AppColors.chineseWhite.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 4),
                              Text(highlight['name'], style: const TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}