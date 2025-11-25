import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../components/favorite_tile.dart';
import '../components/stores/store_modal.dart'; 

class AllFavoriteStoresPage extends StatelessWidget {
  final List<Map<String, dynamic>> stores;

  const AllFavoriteStoresPage({super.key, required this.stores});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text("Lojas Preferidas", style: TextStyle(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          return FavoriteTile(
            item: store,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => StoreModal(
                  store: store,
                  allStores: stores, // <--- CORREÇÃO: Passando a lista 'stores'
                ),
              );
            },
          );
        },
      ),
    );
  }
}