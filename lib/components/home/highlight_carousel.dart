import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class HighlightCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> highlights;
  final Function(Map<String, dynamic>) onHighlightTap;

  const HighlightCarousel({
    super.key,
    required this.highlights,
    required this.onHighlightTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.9),
          itemCount: highlights.length,
          itemBuilder: (context, index) => _buildHighlightCard(highlights[index]),
        ),
      ),
    );
  }

  Widget _buildHighlightCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => onHighlightTap(item),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(item['img']),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['offer'],
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text(item['name'],
                      style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (item['isFavorite'])
              const Positioned(
                top: 16,
                right: 16,
                child: Icon(Icons.favorite, color: Color.fromARGB(255, 255, 255, 255), size: 28),
              )
          ],
        ),
      ),
    );
  }
}