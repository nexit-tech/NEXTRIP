import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../components/custom_search_bar.dart';
import '../components/stores/store_grid_item.dart';
import '../components/stores/top_store_card.dart';
import '../components/filter_modal.dart';
import '../components/stores/store_modal.dart'; // <--- IMPORT NOVO DO MODAL

class StoresPage extends StatefulWidget {
  const StoresPage({super.key});

  @override
  State<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  String _searchQuery = '';
  
  // Dados Mockados com RATING
// Dados Mockados com RATING e COORDENADAS (Lat/Lng)
  final List<Map<String, dynamic>> _allStores = [
    {
      'name': 'Apple', 
      'category': 'Eletrônicos', 
      'rating': 5.0, 
      'img': 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9997, 'lng': -43.3505 // Village Mall
    },
    {
      'name': 'Nike', 
      'category': 'Esportes', 
      'rating': 4.9, 
      'img': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500&auto=format&fit=crop',
      'lat': -23.0005, 'lng': -43.3315 // Barra Shopping
    },
    {
      'name': 'Outback', 
      'category': 'Gastronomia', 
      'rating': 4.8, 
      'img': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9820, 'lng': -43.2177 // Shopping Leblon
    },
    {
      'name': 'Zara', 
      'category': 'Moda', 
      'rating': 4.7, 
      'img': 'https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9515, 'lng': -43.1845 // Botafogo Praia
    },
    {
      'name': 'Starbucks', 
      'category': 'Cafés', 
      'rating': 4.8, 
      'img': 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9698, 'lng': -43.1869 // Copacabana
    },
    {
      'name': 'Burger King', 
      'category': 'Fast Food', 
      'rating': 4.5, 
      'img': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9035, 'lng': -43.1735 // Centro
    },
    {
      'name': 'Reserva', 
      'category': 'Moda Masc.', 
      'rating': 4.6, 
      'img': 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9843, 'lng': -43.1985 // Ipanema
    },
    {
      'name': 'Adidas', 
      'category': 'Esportes', 
      'rating': 4.4, 
      'img': 'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9230, 'lng': -43.2350 // Tijuca
    },
    {
      'name': 'CVC', 
      'category': 'Viagens', 
      'rating': 4.2, 
      'img': 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9068, 'lng': -43.1729 // Centro
    },
  ];

  List<Map<String, dynamic>> _displayList = [];

  @override
  void initState() {
    super.initState();
    _displayList = List.from(_allStores);
  }

  void _filterStores(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _displayList = List.from(_allStores);
      } else {
        _displayList = _allStores.where((store) {
          return store['name'].toLowerCase().contains(query.toLowerCase()) ||
                 store['category'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        onApply: (sortOption) {
          Navigator.pop(context);
          setState(() {
            if (sortOption == 'Populares') {
              _displayList.sort((a, b) => b['rating'].compareTo(a['rating']));
            } else if (sortOption == 'Relevância') {
              _displayList = List.from(_allStores); 
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Filtro aplicado: $sortOption", style: const TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
            )
          );
        },
      ),
    );
  }

  // --- FUNÇÃO PARA ABRIR O MODAL DA LOJA ---
void _openStoreProfile(Map<String, dynamic> store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StoreModal(
        store: store,
        allStores: _allStores, // <--- Passando a lista completa aqui!
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty;
    
    List<Map<String, dynamic>> topStores = [];
    List<Map<String, dynamic>> otherStores = [];

    if (!isSearching) {
      topStores = _displayList.take(5).toList();
      otherStores = _displayList.skip(5).toList();
    } else {
      otherStores = _displayList;
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 1. Cabeçalho
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

            // 2. Barra de Busca
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

            // --- CARROSSEL (SE NÃO TIVER BUSCANDO) ---
            if (!isSearching) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text("EM DESTAQUE", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
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
                        // Conectado aqui:
                        onTap: () => _openStoreProfile(topStores[index]), 
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: Text("TODAS AS LOJAS", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ),
              ),
            ],

            // --- GRID PRINCIPAL ---
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: otherStores.isEmpty
                  ? const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.only(top: 50), child: Center(child: Text("Nenhuma loja encontrada.", style: TextStyle(color: AppColors.chineseWhite)))))
                  : SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return StoreGridItem(
                            store: otherStores[index],
                            // Conectado aqui também:
                            onTap: () => _openStoreProfile(otherStores[index]),
                          );
                        },
                        childCount: otherStores.length,
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
    );
  }
}