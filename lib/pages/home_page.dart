import 'package:flutter/material.dart';
import 'package:app_v7_web/theme/app_colors.dart';
import 'package:app_v7_web/components/custom_navbar.dart';
import 'package:app_v7_web/pages/profile_page.dart';
import 'package:app_v7_web/pages/subscription_page.dart';
import 'package:app_v7_web/pages/stores_page.dart';
import 'package:app_v7_web/pages/travel_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:app_v7_web/components/home/home_app_bar.dart';
import 'package:app_v7_web/components/home/highlight_carousel.dart';
import 'package:app_v7_web/components/home/category_filters.dart';
import 'package:app_v7_web/components/home/deals_grid.dart';
import 'package:app_v7_web/components/deal_modal.dart';
import 'package:app_v7_web/components/filter_modal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _supabase = Supabase.instance.client;
  int _currentIndex = 0;
  String _selectedCategory = 'Todas';
  String _searchQuery = '';
  List<Map<String, dynamic>> _allDeals = [];
  List<Map<String, dynamic>> _filteredDeals = [];
  List<Map<String, dynamic>> _highlights = [];
  bool _isVip = false; // Estado do VIP
  bool _isLoadingDeals = true;

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    final user = _supabase.auth.currentUser;

    try {
      // 1. Busca status VIP do usuário primeiro
      bool currentUserIsVip = false;
      if (user != null) {
        final profileResponse = await _supabase
            .from('profiles')
            .select('is_vip')
            .eq('id', user.id)
            .maybeSingle();

        if (profileResponse != null) {
            currentUserIsVip = profileResponse['is_vip'] ?? false;
        }
      }

      // 2. Busca todas as ofertas ativas
      final response = await _supabase
          .from('deals')
          .select('*, stores(name, category, latitude, longitude, phone, address)')
          .eq('is_active', true)
          .order('redemptions', ascending: false);

      if (response == null) return;

      // 3. Busca os IDs dos favoritos do usuário logado
      Set<String> favoriteIds = {};
      if (user != null) {
        final favResponse = await _supabase
            .from('user_favorites')
            .select('deal_id')
            .eq('user_id', user.id);
        
        if (favResponse != null) {
          favoriteIds = (favResponse as List)
              .map((e) => e['deal_id'] as String?)
              .whereType<String>()
              .toSet();
        }
      }

      final dataList = response as List<dynamic>;
      
      final cleanedData = dataList.map((item) {
        final store = item['stores'] as Map<String, dynamic>? ?? {};
        double original = (item['original_price'] as num).toDouble();
        double discountVal = (item['discount_value'] as num).toDouble();
        String type = item['discount_type'];
        double finalPrice = 0.0;
        String offerText = "";

        if (type == 'percentage') {
          finalPrice = original - (original * (discountVal / 100));
          offerText = "${discountVal.toInt()}% OFF";
        } else {
          finalPrice = original - discountVal;
          offerText = "R\$ ${discountVal.toInt()} OFF";
        }

        return {
          'id': item['id'],
          'store_id': item['store_id'],
          'name': item['title'],
          'description': item['description'],
          'img': item['image_url'] ?? 'https://placehold.co/600x400/png',
          'store_name': store['name'] ?? 'Parceiro',
          'category': store['category'] ?? 'Geral',
          'phone': store['phone'],
          'address': store['address'],
          'lat': (store['latitude'] as num?)?.toDouble(),
          'lng': (store['longitude'] as num?)?.toDouble(),
          'original_price': original,
          'final_price': finalPrice,
          'offer': offerText,
          'redemptions': item['redemptions'] ?? 0,
          'isFavorite': favoriteIds.contains(item['id']), 
        };
      }).toList();

      if (mounted) {
        setState(() {
          _allDeals = cleanedData;
          _filteredDeals = cleanedData;
          _highlights = cleanedData.take(3).toList(); 
          _isVip = currentUserIsVip; // <--- ATUALIZA O ESTADO AQUI
          _isLoadingDeals = false;
        });
        _runFilter();
      }
    } catch (e) {
      debugPrint("Erro Deals: $e");
      if (mounted) setState(() => _isLoadingDeals = false);
    }
  }

  // --- LÓGICA DO FAVORITO (REAL NO BANCO) ---
  Future<void> _toggleFavorite(Map<String, dynamic> item) async {
    final user = _supabase.auth.currentUser;
    
    if (user == null) {
      _showSnackBar("Faça login para favoritar!", icon: Icons.lock_outline);
      return;
    }

    setState(() {
      item['isFavorite'] = !item['isFavorite'];
    });

    try {
      if (item['isFavorite']) {
        await _supabase.from('user_favorites').insert({
          'user_id': user.id,
          'deal_id': item['id'],
        });
      } else {
        await _supabase.from('user_favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('deal_id', item['id']);
      }
    } catch (e) {
      setState(() {
        item['isFavorite'] = !item['isFavorite'];
      });
      debugPrint("Erro ao favoritar: $e");
      _showSnackBar("Erro ao salvar favorito.", icon: Icons.error_outline);
    }
  }

  void _runFilter() {
    setState(() {
      _filteredDeals = _allDeals.where((deal) {
        final categoryMatches = _selectedCategory == 'Todas' || deal['category'] == _selectedCategory;
        final searchMatches = deal['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        return categoryMatches && searchMatches;
      }).toList();
    });
  }

  void _showDealDetails(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DealModal(
        item: item,
        isFavorite: item['isFavorite'],
        onFavoriteToggle: () => _toggleFavorite(item),
      ),
    );
  }

  void _showSnackBar(String msg, {IconData icon = Icons.info_outline}) { 
    ScaffoldMessenger.of(context).clearSnackBars(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.black, size: 20), 
            const SizedBox(width: 12), 
            Expanded(child: Text(msg, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)))
          ]
        ), 
        backgroundColor: AppColors.white, 
        behavior: SnackBarBehavior.floating, 
        margin: const EdgeInsets.all(16), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
      )
    ); 
  }
  
  void _showFilterModal() { 
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent, 
      builder: (context) => FilterModal(onApply: (s) => Navigator.pop(context))
    ); 
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeBody(),
      StoresPage(),
      const TravelPage(),
      // O ProfilePage agora tem um callback para atualizar o _isVip
      ProfilePage(isVip: _isVip, onVipStatusChanged: (s) => setState(() => _isVip = s)),
    ];

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          screens[_currentIndex],
          
          // --- CONDIÇÃO AJUSTADA ---
          // SÓ MOSTRA SE ESTIVER NA TELA HOME (0) E NÃO FOR VIP (!isVip)
          if (_currentIndex == 0 && !_isVip)
            Positioned(
              bottom: 16, 
              right: 16, 
              child: FloatingActionButton(
                onPressed: () async { 
                  final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionPage())); 
                  // Se o pagamento foi concluído, o ProfilePage's onVipStatusChanged lida com isso.
                  if(res==true) setState(()=>_isVip=true); 
                }, 
                backgroundColor: AppColors.white, 
                child: const Icon(FontAwesomeIcons.crown, color: AppColors.black)
              )
            ),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
    );
  }

  Widget _buildHomeBody() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          HomeAppBar(
            onSearchChanged: (v) { _searchQuery = v; _runFilter(); }, 
            onFilterTap: _showFilterModal, 
            isCalculatingLocation: false
          ),
          
          if (!_isLoadingDeals && _highlights.isNotEmpty) 
            HighlightCarousel(
              highlights: _highlights, 
              onHighlightTap: (item) => _showDealDetails(context, item),
              onFavoriteToggle: (item) => _toggleFavorite(item),
            ),

          CategoryFilters(
            selectedCategory: _selectedCategory, 
            onCategorySelected: (c) => setState(() { _selectedCategory = c; _runFilter(); })
          ),
          
          if (_isLoadingDeals) 
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white)))) 
          else 
            DealsGrid(
              deals: _filteredDeals, 
              onDealTap: (item) => _showDealDetails(context, item),
              onFavoriteToggle: (item) => _toggleFavorite(item), 
            ),
            
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}