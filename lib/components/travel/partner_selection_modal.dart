import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../theme/app_colors.dart';
import '../custom_button.dart';
import '../filter_modal.dart'; // Import do Modal de Filtro

class PartnerSelectionModal extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onPartnersSelected;

  const PartnerSelectionModal({super.key, required this.onPartnersSelected});

  @override
  State<PartnerSelectionModal> createState() => _PartnerSelectionModalState();
}

class _PartnerSelectionModalState extends State<PartnerSelectionModal> {
  final _supabase = Supabase.instance.client;
  
  String _searchQuery = '';
  String _selectedCategory = 'Todas';
  String _sortOption = 'Relevância';
  
  List<Map<String, dynamic>> _allDeals = [];
  List<Map<String, dynamic>> _selectedItems = [];
  bool _isLoading = true;

  // Começa com 'Todas' e será preenchida dinamicamente
  List<String> _categories = ['Todas']; 

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    try {
      final response = await _supabase
          .from('deals')
          .select('*, stores(name, category, rating)') 
          .eq('is_active', true);

      if (response == null) {
        setState(() => _isLoading = false);
        return;
      }

      final data = List<Map<String, dynamic>>.from(response);
      
      final cleanedData = data.map((item) {
        final store = item['stores'] as Map<String, dynamic>? ?? {};
        
        double original = (item['original_price'] as num).toDouble();
        double discountVal = (item['discount_value'] as num).toDouble();
        String type = item['discount_type'];
        
        double finalPrice = 0.0;
        double savings = 0.0;

        if (type == 'percentage') {
          savings = original * (discountVal / 100);
          finalPrice = original - savings;
        } else {
          savings = discountVal;
          finalPrice = original - savings;
        }

        return {
          'id': item['id'],
          'name': item['title'],
          'store_name': store['name'],
          'category': store['category'] ?? 'Geral',
          'rating': (store['rating'] as num?)?.toDouble() ?? 0.0,
          'price': finalPrice,
          'original_price': original,
          'discount': savings,
          'qty': 1,
        };
      }).toList();

      // --- EXTRAI AS CATEGORIAS ÚNICAS ---
      final Set<String> uniqueCats = {'Todas'};
      for (var item in cleanedData) {
        if (item['category'] != null && item['category'].toString().isNotEmpty) {
          uniqueCats.add(item['category']);
        }
      }

      if (mounted) {
        setState(() {
          _allDeals = cleanedData;
          _categories = uniqueCats.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erro deals: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredDeals {
    // 1. Filtro de Categoria
    var list = _selectedCategory == 'Todas'
        ? _allDeals
        : _allDeals.where((i) => i['category'] == _selectedCategory).toList();

    // 2. Filtro de Texto
    if (_searchQuery.isNotEmpty) {
      final search = _searchQuery.toLowerCase();
      list = list.where((item) =>
          item['name'].toString().toLowerCase().contains(search) ||
          item['store_name'].toString().toLowerCase().contains(search)).toList();
    }

    // 3. Ordenação
    List<Map<String, dynamic>> sortedList = List.from(list);

    if (_sortOption == 'Maior Desconto') {
      sortedList.sort((a, b) => b['discount'].compareTo(a['discount']));
    } else if (_sortOption == 'Menor Preço') {
      sortedList.sort((a, b) => a['price'].compareTo(b['price']));
    } else if (_sortOption == 'Populares') {
      sortedList.sort((a, b) => b['rating'].compareTo(a['rating']));
    }

    return sortedList;
  }

  void _addItem(Map<String, dynamic> item) {
    setState(() {
      _selectedItems.add(Map<String, dynamic>.from(item));
    });
  }

  void _removeItem(String id) {
    setState(() {
      final index = _selectedItems.indexWhere((i) => i['id'] == id);
      if (index != -1) _selectedItems.removeAt(index);
    });
  }

  int _getItemCount(String id) {
    return _selectedItems.where((i) => i['id'] == id).length;
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        onApply: (selectedSort) {
          Navigator.pop(context);
          setState(() => _sortOption = selectedSort);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.eerieBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.nightRider, borderRadius: BorderRadius.circular(2))),
          
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Adicionar do Clube", style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),

          // --- AQUI ESTÃO OS FILTROS DE VOLTA! ---
          
          // 1. Busca + Botão de Ajuste
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.nightRider)),
                    child: TextField(
                      style: const TextStyle(color: AppColors.white),
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: "Buscar ofertas...",
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showSortModal,
                  child: Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _sortOption != 'Relevância' ? Colors.green : AppColors.nightRider),
                    ),
                    child: Icon(Icons.tune, color: _sortOption != 'Relevância' ? Colors.green : AppColors.white),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Categorias Horizontais
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? AppColors.white : AppColors.nightRider),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? AppColors.black : AppColors.chineseWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          const Divider(color: AppColors.nightRider, height: 1),

          // --- LISTA DE OFERTAS ---
          Expanded(
            child: _isLoading
                ? Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 40))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: _filteredDeals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _filteredDeals[index];
                      return _buildDealItem(item);
                    },
                  ),
          ),

          if (_selectedItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'ADICIONAR (${_selectedItems.length}) ITENS',
                  onPressed: () {
                    widget.onPartnersSelected(_selectedItems);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDealItem(Map<String, dynamic> item) {
    final count = _getItemCount(item['id']);
    final isSelected = count > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.white : AppColors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.white : AppColors.nightRider, width: isSelected ? 2 : 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['store_name'], style: TextStyle(color: isSelected ? AppColors.black : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(item['name'], style: TextStyle(color: isSelected ? AppColors.black : AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("R\$ ${item['original_price'].toStringAsFixed(0)}", style: TextStyle(color: isSelected ? Colors.grey : AppColors.chineseWhite.withOpacity(0.5), decoration: TextDecoration.lineThrough, fontSize: 12)),
                    const SizedBox(width: 8),
                    Text("R\$ ${item['price'].toStringAsFixed(0)}", style: TextStyle(color: isSelected ? AppColors.black : AppColors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                  ],
                )
              ],
            ),
          ),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                child: Text("Eco: R\$ ${item['discount'].toStringAsFixed(0)}", style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              
              if (!isSelected)
                GestureDetector(
                  onTap: () => _addItem(item),
                  child: const Icon(Icons.add_circle_outline, color: AppColors.white, size: 28),
                )
              else
                Container(
                  decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      GestureDetector(onTap: () => _removeItem(item['id']), child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.remove, color: Colors.white, size: 16))),
                      Text("$count", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      GestureDetector(onTap: () => _addItem(item), child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.add, color: Colors.white, size: 16))),
                    ],
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}