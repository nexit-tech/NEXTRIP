import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../components/favorite_tile.dart';
import '../components/deal_modal.dart'; // <--- Import do Modal

class AllFavoriteDealsPage extends StatelessWidget {
  final List<Map<String, dynamic>> deals;

  const AllFavoriteDealsPage({super.key, required this.deals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text("Promoções Preferidas", style: TextStyle(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: deals.length,
        itemBuilder: (context, index) {
          final deal = deals[index];
          return FavoriteTile(
            item: deal,
            onTap: () {
              // ABRE O MODAL DA PROMOÇÃO
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DealModal(
                  item: deal,
                  isFavorite: true, // Já está nos favoritos
                  onFavoriteToggle: () {
                    // Lógica de desfavoritar (futuro)
                    Navigator.pop(context);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}