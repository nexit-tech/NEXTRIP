import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../components/custom_button.dart';
import '../components/travel/budget_summary_card.dart';
import '../components/travel/partner_selection_modal.dart';

class TripPlannerPage extends StatefulWidget {
  final Map<String, dynamic>? tripToEdit; // <--- Recebe dados para edição

  const TripPlannerPage({super.key, this.tripToEdit});

  @override
  State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
  final _destinationController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Lista de itens do roteiro
  List<Map<String, dynamic>> _plannedItems = [];

  // Cálculos
  double get totalCost => _plannedItems.fold(0, (sum, item) => sum + item['price']);
  double get totalSavings => _plannedItems.fold(0, (sum, item) => sum + item['discount']);

  // --- LÓGICA DE EDIÇÃO ---
  @override
  void initState() {
    super.initState();
    // Se veio uma viagem para editar, preenche os campos
    if (widget.tripToEdit != null) {
      final trip = widget.tripToEdit!;
      _destinationController.text = trip['destination'];
      _startDate = trip['startDate'];
      _endDate = trip['endDate'];
      // Clona a lista para não alterar a referência original antes de salvar
      _plannedItems = List<Map<String, dynamic>>.from(trip['items']);
    }
  }

  // --- NOTIFICAÇÃO PADRONIZADA (BRANCA E FLUTUANTE) ---
  void _showSnackBar(String msg, {IconData icon = Icons.check_circle}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 6,
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

  // Agrupamento Visual (Igual fizemos antes)
  List<Map<String, dynamic>> get _groupedItems {
    final Map<String, Map<String, dynamic>> groupedMap = {};
    for (var item in _plannedItems) {
      final name = item['name'];
      if (groupedMap.containsKey(name)) {
        groupedMap[name]!['qty']++;
      } else {
        final newItem = Map<String, dynamic>.from(item);
        newItem['qty'] = 1;
        groupedMap[name] = newItem;
      }
    }
    return groupedMap.values.toList();
  }

  void _removeOneItem(String itemName) {
    setState(() {
      final index = _plannedItems.indexWhere((i) => i['name'] == itemName);
      if (index != -1) _plannedItems.removeAt(index);
    });
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
          _showSnackBar("${items.length} item(s) adicionado(s)!");
        },
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );
    if (picked != null) setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  // Função de Salvar e Voltar
  void _saveTrip() {
    if (_destinationController.text.isEmpty || _startDate == null || _endDate == null) {
      _showSnackBar("Preencha destino e datas!", icon: Icons.warning);
      return;
    }

    // Monta o objeto da viagem
    final tripData = {
      'id': widget.tripToEdit?['id'] ?? DateTime.now().toString(), // Mantém ID ou cria novo
      'destination': _destinationController.text,
      'startDate': _startDate,
      'endDate': _endDate,
      'items': _plannedItems,
      'totalCost': totalCost,
      'totalSavings': totalSavings,
    };

    // Retorna para a tela anterior com os dados
    Navigator.pop(context, tripData);
  }

  @override
  Widget build(BuildContext context) {
    final groupedList = _groupedItems;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(widget.tripToEdit == null ? "Novo Roteiro" : "Editar Roteiro", style: const TextStyle(color: AppColors.white)),
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
              decoration: const InputDecoration(hintText: "Ex: Paris...", hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
            ),
            const Divider(color: AppColors.nightRider),
            const SizedBox(height: 24),

            Row(
              children: [
                _dateSelector("DATA IDA", _startDate, () => _selectDate(true)),
                const SizedBox(width: 16),
                _dateSelector("DATA VOLTA", _endDate, () => _selectDate(false)),
              ],
            ),
            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("CUSTOS & PARCEIROS", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _showAddItemModal,
                  child: const Text("+ Adicionar", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_plannedItems.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: Text("Adicione itens para ver a mágica da economia.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.chineseWhite))),
              )
            else
              ...groupedList.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.eerieBlack, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(item['icon'], color: AppColors.chineseWhite, size: 18),
                    const SizedBox(width: 12),
                    if (item['qty'] > 1)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4)),
                        child: Text("${item['qty']}x", style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    Expanded(child: Text(item['name'], style: const TextStyle(color: AppColors.white))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("R\$ ${(item['price'] * item['qty']).toStringAsFixed(0)}", style: const TextStyle(color: AppColors.white)),
                        if (item['discount'] > 0)
                          Text("- R\$ ${(item['discount'] * item['qty']).toStringAsFixed(0)}", style: const TextStyle(color: Colors.greenAccent, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _removeOneItem(item['name']),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(border: Border.all(color: Colors.redAccent.withOpacity(0.5)), shape: BoxShape.circle),
                        child: const Icon(Icons.remove, color: Colors.redAccent, size: 16),
                      ),
                    )
                  ],
                ),
              )),

            const SizedBox(height: 40),

            BudgetSummaryCard(totalCost: totalCost, totalSavings: totalSavings),

            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'SALVAR ROTEIRO',
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
            Text(date == null ? "--/--" : "${date.day}/${date.month}/${date.year}", style: const TextStyle(color: AppColors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}