import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme/app_colors.dart';
import '../components/stores/store_grid_item.dart';
import '../components/stores/store_modal.dart';

class AllFavoriteStoresPage extends StatefulWidget {
  final List<Map<String, dynamic>> stores; // Mantido para compatibilidade

  const AllFavoriteStoresPage({super.key, required this.stores});

  @override
  State<AllFavoriteStoresPage> createState() => _AllFavoriteStoresPageState();
}

class _AllFavoriteStoresPageState extends State<AllFavoriteStoresPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _favoriteStores = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Busca itens na tabela de favoritos que tenham store_id preenchido
      final response = await _supabase
          .from('user_favorites')
          .select('stores(*)') // Join com a tabela stores
          .eq('user_id', user.id)
          .not('store_id', 'is', null);

      final List<Map<String, dynamic>> loaded = [];

      for (var item in response) {
        final storeData = item['stores'];
        if (storeData != null) {
          loaded.add({
            ...storeData,
            'img': storeData['image_url'] ?? '',
            'lat': (storeData['latitude'] as num?)?.toDouble(),
            'lng': (storeData['longitude'] as num?)?.toDouble(),
            'rating': (storeData['rating'] as num?)?.toDouble() ?? 0.0,
            'total_redemptions': (storeData['total_redemptions'] as num?)?.toInt() ?? 0,
          });
        }
      }

      if (mounted) {
        setState(() {
          _favoriteStores = loaded;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erro lojas fav: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(String storeId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Remove do banco
      await _supabase
          .from('user_favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('store_id', storeId);

      // Remove da lista visualmente na hora
      setState(() {
        _favoriteStores.removeWhere((store) => store['id'] == storeId);
      });
      
    } catch (e) {
      debugPrint("Erro ao remover favorito: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao remover.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text("Lojas Preferidas", style: TextStyle(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: _isLoading
          ? Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 40))
          : _favoriteStores.isEmpty
              ? const Center(child: Text("Nenhuma loja favorita ainda.", style: TextStyle(color: AppColors.chineseWhite)))
              : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _favoriteStores.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final store = _favoriteStores[index];
                    return StoreGridItem(
                      store: store,
                      // --- CORREÇÃO AQUI ---
                      isFavorite: true, // Se está nessa tela, é favorito
                      onFavoriteToggle: () => _removeFavorite(store['id']), // Clicar remove da lista
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) => StoreModal(
                            store: store,
                            allStores: _favoriteStores,
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}