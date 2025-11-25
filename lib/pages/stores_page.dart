import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:app_v7_web/theme/app_colors.dart';
import 'package:app_v7_web/components/custom_search_bar.dart';
import 'package:app_v7_web/components/stores/store_grid_item.dart';
import 'package:app_v7_web/components/stores/top_store_card.dart';
import 'package:app_v7_web/components/filter_modal.dart';
import 'package:app_v7_web/components/stores/store_modal.dart';

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  final _supabase = Supabase.instance.client;
  
  String _searchQuery = '';
  bool _isLoading = true;
  
  List<Map<String, dynamic>> _allStores = [];
  List<Map<String, dynamic>> _displayList = [];

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  Future<void> _fetchStores() async {
    try {
      setState(() => _isLoading = true);

      // Busca lojas ordenadas por RATING padrão
      final response = await _supabase
          .from('stores')
          .select()
          .eq('is_active', true)
          .order('rating', ascending: false);

      if (response == null) {
        setState(() => _isLoading = false);
        return;
      }

      final List<dynamic> dataList = response as List<dynamic>;
      final cleanedData = dataList.map((item) {
        if (item is! Map) return <String, dynamic>{};
        
        final Map<String, dynamic> store = Map<String, dynamic>.from(item);

        return {
          ...store,
          'img': store['image_url'] ?? 'https://placehold.co/600x400/png',
          'lat': (store['latitude'] as num?)?.toDouble(),
          'lng': (store['longitude'] as num?)?.toDouble(),
          'rating': (store['rating'] as num?)?.toDouble() ?? 0.0,
          'total_redemptions': (store['total_redemptions'] as num?)?.toInt() ?? 0, // Novo campo
        };
      }).toList();

      if (mounted) {
        setState(() {
          _allStores = cleanedData;
          _displayList = cleanedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ERRO CRÍTICO NA LOJA: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterStores(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _displayList = List.from(_allStores);
      } else {
        _displayList = _allStores.where((store) {
          final name = store['name'].toString().toLowerCase();
          final category = store['category']?.toString().toLowerCase() ?? '';
          final search = query.toLowerCase();
          return name.contains(search) || category.contains(search);
        }).toList();
      }
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        // --- AQUI ESTÃO AS OPÇÕES PERSONALIZADAS ---
        options: const [
          'Relevância',
          'Mais Bem Avaliadas',
          'Populares',
          'Menor Distância'
        ],
        onApply: (sortOption) {
          Navigator.pop(context);
          setState(() {
            if (sortOption == 'Mais Bem Avaliadas') {
              // Ordena por Rating (Maior para menor)
              _displayList.sort((a, b) => b['rating'].compareTo(a['rating']));
            } else if (sortOption == 'Populares') {
              // Ordena por Total de Cupons Retirados (Maior para menor)
              _displayList.sort((a, b) => b['total_redemptions'].compareTo(a['total_redemptions']));
            } else if (sortOption == 'Relevância') {
              // Volta ao padrão (que já era rating no fetch, ou alfabético se preferir)
              _displayList = List.from(_allStores); 
            } else if (sortOption == 'Menor Distância') {
              // Lógica de GPS simulada (pode implementar geolocator real igual na Home)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Calculando proximidade...", style: TextStyle(color: Colors.black)), backgroundColor: Colors.white),
              );
            }
          });
        },
      ),
    );
  }

  void _openStoreProfile(Map<String, dynamic> store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoreModal(
        store: store,
        allStores: _allStores,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: AppColors.white,
            size: 40,
          ),
        ),
      );
    }

    final isSearching = _searchQuery.isNotEmpty;
    
    List<Map<String, dynamic>> topStores = [];
    List<Map<String, dynamic>> gridStores = [];

    if (!isSearching && _displayList.isNotEmpty) {
      int highlightCount = _displayList.length >= 3 ? 3 : _displayList.length;
      topStores = _displayList.take(highlightCount).toList();
      gridStores = _displayList.skip(highlightCount).toList();
    } else {
      gridStores = _displayList;
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchStores,
          color: AppColors.black,
          backgroundColor: AppColors.white,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.black,
                floating: true,
                pinned: false,
                toolbarHeight: 80,
                centerTitle: true,
                title: Column(
                  children: const [
                    Text("PARCEIROS OFICIAIS", style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
                    SizedBox(height: 4),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: CustomSearchBar(
                    hintText: "Buscar lojas",
                    onChanged: _filterStores,
                    onFilterTap: _showFilterModal,
                  ),
                ),
              ),

              if (!isSearching && topStores.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Row(
                      children: const [
                        SizedBox(width: 8),
                        Text("Destaques", style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: topStores.length,
                      itemBuilder: (context, index) {
                        return TopStoreCard(
                          store: topStores[index],
                          onTap: () => _openStoreProfile(topStores[index]), 
                        );
                      },
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                    child: Text("OUTRAS LOJAS", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ),
              ],

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: gridStores.isEmpty && topStores.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50), 
                          child: Center(child: Text("Nenhuma loja encontrada.", style: TextStyle(color: AppColors.chineseWhite)))
                        )
                      )
                    : SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return StoreGridItem(
                              store: gridStores[index],
                              onTap: () => _openStoreProfile(gridStores[index]),
                            );
                          },
                          childCount: gridStores.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                      ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}