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
import 'package:geolocator/geolocator.dart';
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
  bool _isCalculatingLocation = false;
  bool _isVip = false;
  bool _isLoadingDeals = true;

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    try {
      final response = await _supabase
          .from('deals')
          .select('*, stores(name, category, latitude, longitude, phone, address)')
          .eq('is_active', true)
          .order('redemptions', ascending: false);

      if (response == null) return;

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
          'isFavorite': false, // Começa falso, mas vamos mudar isso em breve
        };
      }).toList();

      if (mounted) {
        setState(() {
          _allDeals = cleanedData;
          _filteredDeals = cleanedData;
          _highlights = cleanedData.take(3).toList(); 
          _isLoadingDeals = false;
        });
      }
    } catch (e) {
      debugPrint("Erro Deals: $e");
      if (mounted) setState(() => _isLoadingDeals = false);
    }
  }

  // --- LÓGICA DO FAVORITO ---
  void _toggleFavorite(Map<String, dynamic> item) {
    setState(() {
      item['isFavorite'] = !item['isFavorite'];
    });
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
        // Passamos a função para o modal atualizar a Home
        onFavoriteToggle: () => _toggleFavorite(item),
      ),
    );
  }

  // ... Métodos auxiliares (SnackBar, FilterModal, etc)
  void _showSnackBar(String msg, {IconData icon = Icons.info_outline}) { ScaffoldMessenger.of(context).clearSnackBars(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Icon(icon, color: AppColors.black, size: 20), const SizedBox(width: 12), Expanded(child: Text(msg, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold)))]), backgroundColor: AppColors.white, behavior: SnackBarBehavior.floating, margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))); }
  void _showFilterModal() { showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (context) => FilterModal(onApply: (s) => Navigator.pop(context))); }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeBody(),
      StoresPage(),
      const TravelPage(),
      ProfilePage(isVip: _isVip, onVipStatusChanged: (s) => setState(() => _isVip = s)),
    ];

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          screens[_currentIndex],
          if (_currentIndex == 0 && !_isVip)
            Positioned(bottom: 16, right: 16, child: FloatingActionButton(onPressed: () async { final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionPage())); if(res==true) setState(()=>_isVip=true); }, backgroundColor: AppColors.white, child: const Icon(FontAwesomeIcons.crown, color: AppColors.black))),
        ],
      ),
      bottomNavigationBar: CustomNavBar(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
    );
  }

  Widget _buildHomeBody() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          HomeAppBar(onSearchChanged: (v) { _searchQuery = v; _runFilter(); }, onFilterTap: _showFilterModal, isCalculatingLocation: false),
          
          if (!_isLoadingDeals && _highlights.isNotEmpty) 
            HighlightCarousel(
              highlights: _highlights, 
              onHighlightTap: (item) => _showDealDetails(context, item),
              onFavoriteToggle: (item) => _toggleFavorite(item), // <--- Passando a função pro Carrossel
            ),

          CategoryFilters(selectedCategory: _selectedCategory, onCategorySelected: (c) => setState(() { _selectedCategory = c; _runFilter(); })),
          
          if (_isLoadingDeals) 
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.white)))) 
          else 
            DealsGrid(
              deals: _filteredDeals, 
              onDealTap: (item) => _showDealDetails(context, item),
              onFavoriteToggle: (item) => _toggleFavorite(item), // <--- Passando a função pro Grid
            ),
            
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}