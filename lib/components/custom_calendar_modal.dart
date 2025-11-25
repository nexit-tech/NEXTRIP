import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class CustomCalendarModal extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime?) onRangeSelected;

  const CustomCalendarModal({
    super.key,
    this.startDate,
    this.endDate,
    required this.onRangeSelected,
  });

  @override
  State<CustomCalendarModal> createState() => _CustomCalendarModalState();
}

class _CustomCalendarModalState extends State<CustomCalendarModal> {
  late DateTime _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.startDate ?? DateTime.now();
    _rangeStart = widget.startDate;
    _rangeEnd = widget.endDate;
    initializeDateFormatting('pt_BR', null);
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      // CORREÇÃO DO ERRO DE OVERFLOW: Aumentei a altura e deixei flexível
      height: 650, 
      decoration: const BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.nightRider)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: AppColors.nightRider, borderRadius: BorderRadius.circular(2))),
          ),

          const Text(
            "SELECIONE O PERÍODO",
            style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          
          const SizedBox(height: 24),

          Expanded( // Expanded ajuda a evitar overflow se o calendário crescer
            child: TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              currentDay: DateTime.now(),
              
              // --- LÓGICA DE INTERVALO ---
              rangeSelectionMode: RangeSelectionMode.toggledOn,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              onRangeSelected: _onRangeSelected,
              
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.white),
                rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.white),
              ),
              
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: AppColors.chineseWhite.withOpacity(0.5), fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(color: AppColors.chineseWhite.withOpacity(0.5), fontWeight: FontWeight.bold),
              ),

              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: AppColors.white),
                weekendTextStyle: const TextStyle(color: AppColors.chineseWhite),
                outsideTextStyle: TextStyle(color: AppColors.nightRider),

                // --- ESTILO DO INTERVALO (BRANCO E PRETO) ---
                // Dia de Início (Bolinha Branca)
                rangeStartDecoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                rangeStartTextStyle: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),

                // Dia de Fim (Bolinha Branca)
                rangeEndDecoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                rangeEndTextStyle: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),

                // O Meio do intervalo (Fundo Branco sólido)
                rangeHighlightColor: AppColors.white, 
                // Texto do meio do intervalo (Preto para ler no fundo branco)
                withinRangeTextStyle: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
                
                todayDecoration: BoxDecoration(color: Colors.transparent, shape: BoxShape.circle, border: Border.all(color: AppColors.white.withOpacity(0.5))),
                todayTextStyle: const TextStyle(color: AppColors.white),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botão Confirmar (Protegido com SafeArea)
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'CONFIRMAR DATAS',
                onPressed: () {
                  if (_rangeStart != null) {
                    widget.onRangeSelected(_rangeStart!, _rangeEnd);
                    Navigator.pop(context);
                  } else {
                    // Feedback se não selecionar nada
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione pelo menos a data de ida.")));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}