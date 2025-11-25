import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_v7_web/theme/app_colors.dart';
import 'package:app_v7_web/components/custom_button.dart';
import 'package:app_v7_web/components/travel/budget_summary_card.dart';
import 'package:app_v7_web/components/travel/partner_selection_modal.dart';
import 'package:app_v7_web/components/custom_calendar_modal.dart';

class TripPlannerPage extends StatefulWidget {
  final Map<String, dynamic>? tripToEdit; 

  const TripPlannerPage({super.key, this.tripToEdit});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final _supabase = Supabase.instance.client;
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;
  
  // Lista bruta (pode ter repetidos)
  List<Map<String, dynamic>> _plannedItems = [];

  // --- CÁLCULOS FINANCEIROS ---
  double get totalOriginal => _plannedItems.fold(0, (sum, item) => sum + (item['original_price'] ?? item['price']));
  double get totalSavings => _plannedItems.fold(0, (sum, item) => sum + item['discount']);
  double get totalFinal => totalOriginal - totalSavings;

  // --- AGRUPAMENTO VISUAL (CORRIGIDO: Agrupa por NOME) ---
  List<Map<String, dynamic>> get _groupedItems {
    final Map<String, Map<String, dynamic>> grouped = {};
    
    for (var item in _plannedItems) {
      // Usa o NOME como chave. Isso resolve o problema de duplicação ao carregar do banco!
      final String key = item['name'].toString();
      
      if (grouped.containsKey(key)) {
        // Se já tem esse item, só aumenta a quantidade visual
        int currentQty = grouped[key]!['qty'] as int;
        grouped[key]!['qty'] = currentQty + 1;
      } else {
        // Se é novo, cria e inicia com 1
        final newItem = Map<String, dynamic>.from(item);
        newItem['qty'] = 1;
        grouped[key] = newItem;
      }
    }
    return grouped.values.toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.tripToEdit != null) {
      final trip = widget.tripToEdit!;
      _destinationController.text = trip['destination'];
      _startDate = trip['startDate'];
      _endDate = trip['endDate'];
      _plannedItems = List<Map<String, dynamic>>.from(trip['items']);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? Colors.redAccent : AppColors.white,
        content: Text(msg, style: TextStyle(color: isError ? Colors.white : AppColors.black, fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddItemModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PartnerSelectionModal(
        onPartnersSelected: (items) {
          setState(() {
            _plannedItems.addAll(items);
          });
        },
      ),
    );
  }

  // Remove UMA unidade pelo NOME (Decremento inteligente)
  void _removeOneInstance(String itemName) {
    setState(() {
      // Procura o primeiro item com esse nome e remove
      final index = _plannedItems.indexWhere((item) => item['name'].toString() == itemName);
      if (index != -1) {
        _plannedItems.removeAt(index);
      }
    });
  }

  void _selectDateRange() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomCalendarModal(
        startDate: _startDate,
        endDate: _endDate,
        onRangeSelected: (start, end) {
          setState(() {
            _startDate = start;
            _endDate = end;
          });
        },
      ),
    );
  }

  Future<void> _saveTrip() async {
    if (_destinationController.text.isEmpty || _startDate == null) {
      _showSnackBar("Preencha destino e data de ida!", isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      dynamic tripId;

      final tripData = {
        'destination': _destinationController.text,
        'start_date': _startDate!.toIso8601String(),
        'end_date': (_endDate ?? _startDate!).toIso8601String(),
        'total_cost': totalFinal,
        'total_savings': totalSavings,
      };

      if (widget.tripToEdit != null) {
        tripId = widget.tripToEdit!['id'];
        await _supabase.from('trips').update(tripData).eq('id', tripId);
        // Apaga itens antigos para regravar os novos (mais seguro)
        await _supabase.from('trip_items').delete().eq('trip_id', tripId);
      } else {
        final response = await _supabase.from('trips').insert(tripData).select();
        tripId = response[0]['id'];
      }

      if (_plannedItems.isNotEmpty) {
        final itemsToInsert = _plannedItems.map((item) {
          return {
            'trip_id': tripId,
            'name': item['name'],
            'category': item['category'],
            'price': item['price'],
            'discount': item['discount'],
            'qty': 1, // No banco salvamos 1 por 1
            'icon_code': 57563,
          };
        }).toList();

        await _supabase.from('trip_items').insert(itemsToInsert);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Erro salvar: $e");
      _showSnackBar("Erro ao salvar roteiro.", isError: true);
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa a lista agrupada para exibir
    final groupedList = _groupedItems;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text("Planejar Roteiro", style: TextStyle(color: AppColors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("DESTINO", style: TextStyle(color: AppColors.chineseWhite, fontSize: 10, fontWeight: FontWeight.bold)),
            TextField(
              controller: _destinationController,
              style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Ex: Paris...", 
                hintStyle: TextStyle(color: Colors.grey), 
                border: InputBorder.none
              ),
            ),
            const Divider(color: AppColors.nightRider),
            const SizedBox(height: 24),

            Row(
              children: [
                _dateSelector("DATA IDA", _startDate, _selectDateRange),
                const SizedBox(width: 16),
                _dateSelector("DATA VOLTA", _endDate, _selectDateRange),
              ],
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("ITENS DO ROTEIRO", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _showAddItemModal,
                  child: const Text("+ Adicionar Oferta", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_plannedItems.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: Text("Adicione ofertas do app para montar seu orçamento.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.chineseWhite))),
              )
            else
              // --- LISTA AGRUPADA ---
              ...groupedList.map((item) {
                // Cálculos do GRUPO
                double unitOriginal = (item['original_price'] ?? item['price'] ?? 0.0).toDouble();
                double unitFinal = (item['price'] ?? 0.0).toDouble();
                int qty = item['qty'];
                
                double totalOriginalGroup = unitOriginal * qty;
                double totalFinalGroup = unitFinal * qty;
                double totalDiscountGroup = (item['discount'] ?? 0.0) * qty;
                
                // Chave para remoção (Nome)
                String itemName = item['name'].toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.eerieBlack, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      // BADGE 2x (Branco e Preto)
                      if (qty > 1)
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(6)),
                          child: Text("${qty}x", style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.w900, fontSize: 12)),
                        ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['store_name'] ?? 'Oferta', style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(item['name'], style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      
                      // COLUNA DE PREÇOS (O que você pediu!)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Original Riscado
                          if (totalDiscountGroup > 0)
                            Text("R\$ ${totalOriginalGroup.toStringAsFixed(0)}", style: TextStyle(color: AppColors.chineseWhite.withOpacity(0.5), fontSize: 11, decoration: TextDecoration.lineThrough)),
                          
                          // Preço Final
                          Text("R\$ ${totalFinalGroup.toStringAsFixed(0)}", style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          
                          // Desconto Verde
                          if (totalDiscountGroup > 0)
                            Text("- R\$ ${totalDiscountGroup.toStringAsFixed(0)}", style: const TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Botão Remover
                      GestureDetector(
                        onTap: () => _removeOneInstance(itemName),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                            shape: BoxShape.circle
                          ),
                          child: const Icon(Icons.remove, color: Colors.redAccent, size: 16),
                        ),
                      )
                    ],
                  ),
                );
              }),

            const SizedBox(height: 40),

            // Card de Resumo
            BudgetSummaryCard(
              totalOriginal: totalOriginal,
              totalDiscount: totalSavings,
              totalFinal: totalFinal,
            ),

            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'SALVAR ROTEIRO',
                isLoading: _isSaving,
                onPressed: _saveTrip,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _dateSelector(String label, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.chineseWhite, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              date == null ? "--/--" : "${date.day}/${date.month}/${date.year}", 
              style: const TextStyle(color: AppColors.white, fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }
}