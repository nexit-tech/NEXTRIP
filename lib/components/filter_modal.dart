import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class FilterModal extends StatefulWidget {
  final Function(String) onApply;
  final List<String>? options; // <--- Agora aceita opções personalizadas

  const FilterModal({
    super.key, 
    required this.onApply,
    this.options, // Opcional
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String _selectedSort = ''; 
  late List<String> _sortOptions;

  @override
  void initState() {
    super.initState();
    // Se passar opções, usa elas. Se não, usa o padrão da Home.
    _sortOptions = widget.options ?? [
      'Relevância',
      'Menor Distância',
      'Maior Desconto',
      'Populares'
    ];
    _selectedSort = _sortOptions.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.eerieBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(color: AppColors.nightRider, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const Text("Filtrar & Ordenar", style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text("ORDENAR POR", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _sortOptions.map((option) {
              final isSelected = _selectedSort == option;
              return GestureDetector(
                onTap: () => setState(() => _selectedSort = option),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isSelected ? AppColors.white : AppColors.nightRider),
                  ),
                  child: Text(option, style: TextStyle(color: isSelected ? AppColors.black : AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'APLICAR FILTROS',
              onPressed: () => widget.onApply(_selectedSort),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}