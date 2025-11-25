import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../theme/app_colors.dart';
import '../custom_button.dart';

class PartnerSelectionModal extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onPartnersSelected;

  const PartnerSelectionModal({super.key, required this.onPartnersSelected});

  @override
  State<PartnerSelectionModal> createState() => _PartnerSelectionModalState();
}

class _PartnerSelectionModalState extends State<PartnerSelectionModal> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';
  
  // Lista de itens selecionados (Pode ter repetidos)
  final List<Map<String, dynamic>> _selectedItems = [];

  // Base de Dados
  final List<Map<String, dynamic>> _allPartners = [
    {'name': 'Jantar no Outback', 'category': 'Alimentação', 'price': 150.0, 'discount': 30.0, 'icon': Icons.restaurant},
    {'name': 'Café Starbucks', 'category': 'Alimentação', 'price': 40.0, 'discount': 10.0, 'icon': Icons.local_cafe},
    {'name': 'Burger King Combo', 'category': 'Alimentação', 'price': 35.0, 'discount': 15.0, 'icon': FontAwesomeIcons.burger},
    {'name': 'Hotel Ibis Diária', 'category': 'Hospedagem', 'price': 250.0, 'discount': 50.0, 'icon': Icons.hotel},
    {'name': 'Resort All Inclusive', 'category': 'Hospedagem', 'price': 1200.0, 'discount': 200.0, 'icon': FontAwesomeIcons.umbrellaBeach},
    {'name': 'Airbnb Apartamento', 'category': 'Hospedagem', 'price': 400.0, 'discount': 0.0, 'icon': Icons.home},
    {'name': 'Tênis na Nike', 'category': 'Compras', 'price': 600.0, 'discount': 100.0, 'icon': FontAwesomeIcons.shoePrints},
    {'name': 'Roupas na Reserva', 'category': 'Compras', 'price': 400.0, 'discount': 50.0, 'icon': FontAwesomeIcons.tshirt},
    {'name': 'Look na Zara', 'category': 'Compras', 'price': 350.0, 'discount': 30.0, 'icon': FontAwesomeIcons.bagShopping},
    {'name': 'Uber para Aeroporto', 'category': 'Transporte', 'price': 80.0, 'discount': 5.0, 'icon': Icons.directions_car},
    {'name': 'Aluguel de Carro', 'category': 'Transporte', 'price': 180.0, 'discount': 40.0, 'icon': FontAwesomeIcons.car},
  ];

  List<Map<String, dynamic>> get _filteredPartners {
    return _allPartners.where((item) {
      final matchesSearch = item['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Todos' || item['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Adiciona um item à lista
  void _addItem(Map<String, dynamic> item) {
    setState(() {
      _selectedItems.add(item);
    });
  }

  // Remove UMA instância do item da lista
  void _removeItem(Map<String, dynamic> item) {
    setState(() {
      _selectedItems.remove(item); // Remove a primeira ocorrência encontrada
    });
  }

  // Conta quantos desse item temos na lista
  int _getItemCount(Map<String, dynamic> item) {
    return _selectedItems.where((i) => i == item).length;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: 700 + bottomInset,
      decoration: const BoxDecoration(
        color: AppColors.eerieBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.nightRider, borderRadius: BorderRadius.circular(2))),
              
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Adicionar Parceiros", style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),

              // Busca
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.nightRider),
                  ),
                  child: TextField(
                    style: const TextStyle(color: AppColors.white),
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: const InputDecoration(
                      hintText: "Buscar (ex: Outback, Hotel...)",
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _filterChip('Todos'),
                    _filterChip('Alimentação'),
                    _filterChip('Hospedagem'),
                    _filterChip('Compras'),
                    _filterChip('Transporte'),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.nightRider, height: 1),

              // Lista
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  itemCount: _filteredPartners.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _filteredPartners[index];
                    return _buildPartnerItem(item);
                  },
                ),
              ),
            ],
          ),

          // BOTÃO CONFIRMAR
          if (_selectedItems.isNotEmpty)
            Positioned(
              bottom: 24 + bottomInset,
              left: 24,
              right: 24,
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

  Widget _buildPartnerItem(Map<String, dynamic> item) {
    final count = _getItemCount(item);
    final isSelected = count > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.white : AppColors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.white : AppColors.nightRider,
          width: isSelected ? 2 : 1
        ),
      ),
      child: Row(
        children: [
          // Ícone
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.black.withOpacity(0.1) : AppColors.eerieBlack,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item['icon'], color: isSelected ? AppColors.black : AppColors.white, size: 20),
          ),
          const SizedBox(width: 16),
          
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    color: isSelected ? AppColors.black : AppColors.white,
                    fontWeight: FontWeight.bold
                  )
                ),
                const SizedBox(height: 4),
                Text(
                  "Custo: R\$ ${item['price']}",
                  style: TextStyle(
                    color: isSelected ? AppColors.black.withOpacity(0.6) : AppColors.chineseWhite,
                    fontSize: 12
                  )
                ),
              ],
            ),
          ),

          // Coluna de Economia
          if (item['discount'] > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("ECONOMIA", style: TextStyle(color: isSelected ? Colors.grey : Colors.grey, fontSize: 10)),
                  Text(
                    "- R\$ ${item['discount']}", 
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)
                  ),
                ],
              ),
            ),
            
          // --- CONTADOR (AQUI ESTÁ A MÁGICA) ---
          if (!isSelected)
            // Botão de Adicionar Simples (Se for 0)
            GestureDetector(
              onTap: () => _addItem(item),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.nightRider),
                ),
                child: const Icon(Icons.add, color: AppColors.white, size: 16),
              ),
            )
          else
            // Controlador de Quantidade (Se for > 0)
            Container(
              decoration: BoxDecoration(
                color: AppColors.black, // Contraste preto no fundo branco
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Menos
                  GestureDetector(
                    onTap: () => _removeItem(item),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Icon(Icons.remove, color: AppColors.white, size: 14),
                    ),
                  ),
                  
                  // Número
                  Text(
                    count.toString(), 
                    style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)
                  ),

                  // Mais
                  GestureDetector(
                    onTap: () => _addItem(item),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Icon(Icons.add, color: AppColors.white, size: 14),
                    ),
                  ),
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.white : AppColors.nightRider),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.black : AppColors.chineseWhite,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}