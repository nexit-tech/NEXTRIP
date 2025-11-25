import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_colors.dart';
import '../components/custom_navbar.dart';
import '../components/deal_modal.dart';
import '../components/filter_modal.dart';
import 'profile_page.dart';
import 'subscription_page.dart';
import 'stores_page.dart'; // <--- Import novo
import 'travel_page.dart';

// Imports dos Componentes da Home
import '../components/home/home_app_bar.dart';
import '../components/home/highlight_carousel.dart';
import '../components/home/category_filters.dart';
import '../components/home/deals_grid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String _selectedCategory = 'Todas';
  String _searchQuery = '';
  List<Map<String, dynamic>> _filteredDeals = [];
  bool _isCalculatingLocation = false;
  bool _isVip = false;

  // --- DADOS (Highlights) ---
  final List<Map<String, dynamic>> _highlights = [
    {'id': 'h1', 'name': 'Verão Carioca', 'location': 'Rio de Janeiro', 'offer': '50% OFF', 'category': 'Geral', 'img': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?q=80&w=1000&auto=format&fit=crop', 'isFavorite': false},
    {'id': 'h2', 'name': 'Festival Burger', 'location': 'Centro Gastronômico', 'offer': 'Rodízio \$39', 'category': 'Gastronomia', 'img': 'https://images.unsplash.com/photo-1550547660-d9450f859349?q=80&w=1000&auto=format&fit=crop', 'isFavorite': false},
    {'id': 'h3', 'name': 'Tech Week', 'location': 'Barra da Tijuca', 'offer': 'Apple 20%', 'category': 'Eletrônicos', 'img': 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=1000&auto=format&fit=crop', 'isFavorite': false},
  ];

  // --- DADOS (Lojas - Com distance null) ---
  final List<Map<String, dynamic>> _allDeals = [
    {
      'id': '1', 'name': 'Outback', 'location': 'Shopping Leblon', 'offer': '30% no Jantar', 'category': 'Gastronomia', 
      'distance': null, 
      'lat': -22.9820, 'lng': -43.2177, 
      'img': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=500&auto=format&fit=crop', 
      'isFavorite': false
    },
    {
      'id': '2', 'name': 'Reserva', 'location': 'Ipanema', 'offer': 'até 40% OFF', 'category': 'Moda', 
      'distance': null,
      'lat': -22.9843, 'lng': -43.1985, 
      'img': 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?q=80&w=500&auto=format&fit=crop', 
      'isFavorite': false
    },
    {
      'id': '3', 'name': 'Starbucks', 'location': 'Copacabana', 'offer': '2x1 no Café', 'category': 'Gastronomia', 
      'distance': null,
      'lat': -22.9698, 'lng': -43.1869, 
      'img': 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=500&auto=format&fit=crop', 
      'isFavorite': false
    },
    {
      'id': '4', 'name': 'Nike Store', 'location': 'Barra Shopping', 'offer': 'Tênis c/ 15%', 'category': 'Moda', 
      'distance': null,
      'lat': -23.0005, 'lng': -43.3315, 
      'img': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500&auto=format&fit=crop', 
      'isFavorite': false
    },
    {
      'id': '5', 'name': 'Burger King', 'location': 'Centro', 'offer': 'Combo \$19.90', 'category': 'Gastronomia', 
      'distance': null,
      'lat': -22.9035, 'lng': -43.1735, 
      'img': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=500&auto=format&fit=crop', 
      'isFavorite': false
    },
    {
      'id': '6', 'name': 'Zara', 'location': 'Botafogo', 'offer': 'Nova Coleção', 'category': 'Moda', 
      'distance': null,
      'lat': -22.9515, 'lng': -43.1845, 
      'img': 'https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=500&auto=format&fit=crop', 
      'isFavorite': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredDeals = List.from(_allDeals);
  }

  // --- NOTIFICAÇÃO "POP-UP GOSTOSINHO" (AJUSTADA) ---
  void _showSnackBar(String msg, {IconData icon = Icons.info_outline}) {
    ScaffoldMessenger.of(context).clearSnackBars(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.white,
        behavior: SnackBarBehavior.floating, 
        margin: const EdgeInsets.all(16),    
        elevation: 6,
        // Ajustei o padding para ficar mais "slim" (fina)
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: AppColors.black, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  color: AppColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- GEOLOCALIZAÇÃO ---
  Future<void> _sortByLocation() async {
    setState(() => _isCalculatingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('GPS está desativado.', icon: Icons.location_disabled);
      setState(() => _isCalculatingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Permissão negada.', icon: Icons.lock_outline);
        setState(() => _isCalculatingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Permissão negada permanentemente.', icon: Icons.block);
      setState(() => _isCalculatingLocation = false);
      return;
    }

    try {
      Position userPosition = await Geolocator.getCurrentPosition();
      
      setState(() {
        for (var deal in _allDeals) {
          if (deal.containsKey('lat')) {
            double distanceInMeters = Geolocator.distanceBetween(
              userPosition.latitude, userPosition.longitude, 
              deal['lat'], deal['lng']
            );
            deal['distanceVal'] = distanceInMeters;
            deal['distance'] = "${(distanceInMeters / 1000).toStringAsFixed(1)}km";
          }
        }
        _allDeals.sort((a, b) {
          double distA = a['distanceVal'] ?? 999999;
          double distB = b['distanceVal'] ?? 999999;
          return distA.compareTo(distB);
        });
        _runFilter();
        _isCalculatingLocation = false;
      });
      
      _showSnackBar('Ordenado por proximidade!', icon: Icons.near_me);

    } catch (e) {
      debugPrint("Erro GPS: $e");
      setState(() => _isCalculatingLocation = false);
    }
  }

  // --- LÓGICAS DE FILTRO E FAVORITO ---
  void _toggleFavorite(Map<String, dynamic> item, bool isHighlight) {
    setState(() {
      item['isFavorite'] = !item['isFavorite'];
    });
  }

  void _runFilter() {
    setState(() {
      _filteredDeals = _allDeals.where((deal) {
        final categoryMatches = _selectedCategory == 'Todas' || deal['category'] == _selectedCategory;
        final searchMatches = deal['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              deal['offer'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        return categoryMatches && searchMatches;
      }).toList();
    });
  }

  void _showDealDetails(BuildContext context, Map<String, dynamic> item, {bool isHighlight = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DealModal(
        item: item,
        isFavorite: item['isFavorite'],
        onFavoriteToggle: () => _toggleFavorite(item, isHighlight),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        onApply: (selectedSort) {
          Navigator.pop(context);
          if (selectedSort == 'Menor Distância') {
            _sortByLocation();
          } else if (selectedSort == 'Maior Desconto') {
             setState(() {
               _allDeals.sort((a, b) => b['offer'].compareTo(a['offer']));
               _runFilter();
             });
          } else {
            setState(() {
               _allDeals.sort((a, b) => a['id'].compareTo(b['id']));
               _runFilter();
            });
          }
        },
      ),
    );
  }

@override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeBody(),
      const StoresPage(),
      const TravelPage(),
      
      ProfilePage(
        isVip: _isVip, // Passa o estado atual
        onVipStatusChanged: (newStatus) {
          setState(() {
            _isVip = newStatus; // Atualiza o estado da Home
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.black,
      // --- CORREÇÃO DE POSIÇÃO: Usamos Stack para controlar o Z-Index e Posição ---
      body: Stack(
        children: [
          // 1. O Conteúdo da Página
          screens[_currentIndex],

          // 2. O Botão Flutuante (Agora Posicionado manualmente no Stack)
          // Isso faz com que a SnackBar ignore a existência dele e fique lá embaixo!
          if (_currentIndex == 0 && !_isVip)
            Positioned(
              bottom: 16, // Margem de baixo
              right: 16,  // Margem da direita
              child: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
                  if (result == true) {
                    setState(() => _isVip = true);
                    _showSnackBar("Bem-vindo ao Clube VIP!", icon: FontAwesomeIcons.crown);
                  }
                },
                backgroundColor: AppColors.white,
                elevation: 10,
                child: const Icon(FontAwesomeIcons.crown, color: AppColors.black, size: 20),
              ),
            ),
        ],
      ),

      // Nota: Removi o floatingActionButton daqui do Scaffold para usar o do Stack

      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildHomeBody() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          HomeAppBar(
            onSearchChanged: (v) { _searchQuery = v; _runFilter(); },
            onFilterTap: _showFilterModal,
            isCalculatingLocation: _isCalculatingLocation,
          ),
          
          HighlightCarousel(
            highlights: _highlights,
            onHighlightTap: (item) => _showDealDetails(context, item, isHighlight: true),
          ),

          CategoryFilters(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
                _runFilter();
              });
            },
          ),

          DealsGrid(
            deals: _filteredDeals,
            onDealTap: (item) => _showDealDetails(context, item),
          ),

          // Espaço extra no final para rolar tudo e ver o último item sem o botão tapar
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}