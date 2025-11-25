import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme/app_colors.dart';
import '../components/home/deals_grid.dart'; // Reutilizando o grid da home
import '../components/deal_modal.dart';

class AllFavoriteDealsPage extends StatefulWidget {
  final List<Map<String, dynamic>> deals; // Mantendo construtor para compatibilidade, mas vamos ignorar e buscar do banco

  const AllFavoriteDealsPage({super.key, required this.deals});

  @override
  State<AllFavoriteDealsPage> createState() => _AllFavoriteDealsPageState();
}

class _AllFavoriteDealsPageState extends State<AllFavoriteDealsPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _favoriteDeals = [];

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Busca favoritos onde deal_id não é nulo
      // O select faz um Join para trazer os dados da tabela 'deals' e 'stores'
      final response = await _supabase
          .from('user_favorites')
          .select('deals(*, stores(name))') 
          .eq('user_id', user.id)
          .not('deal_id', 'is', null);

      final List<Map<String, dynamic>> loaded = [];

      for (var item in response) {
        final dealData = item['deals'];
        if (dealData != null) {
          final store = dealData['stores'] ?? {};
          
          // Formata igual a Home
          double original = (dealData['original_price'] as num).toDouble();
          double finalVal = 0;
          double discountVal = (dealData['discount_value'] as num).toDouble();
          String offerText = "";

          if (dealData['discount_type'] == 'percentage') {
            finalVal = original - (original * (discountVal / 100));
            offerText = "${discountVal.toInt()}% OFF";
          } else {
            finalVal = original - discountVal;
            offerText = "R\$ ${discountVal.toInt()} OFF";
          }

          loaded.add({
            'id': dealData['id'],
            'name': dealData['title'],
            'img': dealData['image_url'] ?? '',
            'store_name': store['name'],
            'original_price': original,
            'final_price': finalVal,
            'offer': offerText,
            'isFavorite': true, // Óbvio, pois está na lista de favoritos
            // Campos extras pro modal
            'description': dealData['description'],
            'store_id': dealData['store_id'],
          });
        }
      }

      if (mounted) {
        setState(() {
          _favoriteDeals = loaded;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erro favoritos: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: const Text("Minhas Promoções", style: TextStyle(color: AppColors.white)),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: _isLoading
          ? Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 40))
          : CustomScrollView(
              slivers: [
                DealsGrid(
                  deals: _favoriteDeals,
                  onDealTap: (item) {
                     showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => DealModal(
                          item: item,
                          isFavorite: true,
                          onFavoriteToggle: () async {
                             // Remove da lista localmente e do banco
                             await _supabase.from('user_favorites').delete().eq('deal_id', item['id']).eq('user_id', _supabase.auth.currentUser!.id);
                             Navigator.pop(context);
                             _fetchFavorites(); // Recarrega
                          },
                        ),
                      );
                  },
                  onFavoriteToggle: (item) async {
                     // Lógica rápida de remover
                     await _supabase.from('user_favorites').delete().eq('deal_id', item['id']).eq('user_id', _supabase.auth.currentUser!.id);
                     _fetchFavorites(); // Recarrega a tela
                  },
                )
              ],
            ),
    );
  }
}