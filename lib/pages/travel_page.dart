import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:app_v7_web/theme/app_colors.dart';
import 'package:app_v7_web/pages/trip_planner_page.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _myTrips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrips();
  }

  Future<void> _fetchTrips() async {
    try {
      setState(() => _isLoading = true);
      
      // Busca as viagens ordenadas pela data mais recente
      final response = await _supabase
          .from('trips')
          .select()
          .order('start_date', ascending: true);

      if (response == null) {
        setState(() => _isLoading = false);
        return;
      }

      final data = List<Map<String, dynamic>>.from(response);
      
      // Conversão de tipos (Banco -> Flutter)
      final cleanedData = data.map((trip) {
        return {
          'id': trip['id'],
          'destination': trip['destination'],
          'startDate': DateTime.parse(trip['start_date']),
          'endDate': DateTime.parse(trip['end_date']),
          'totalCost': (trip['total_cost'] as num?)?.toDouble() ?? 0.0,
          'totalSavings': (trip['total_savings'] as num?)?.toDouble() ?? 0.0,
          // Itens não vêm nessa query inicial, buscamos se precisar editar
        };
      }).toList();

      if (mounted) {
        setState(() {
          _myTrips = cleanedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro trips: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Abre o planejador e espera o resultado (Salvar)
  Future<void> _openTripPlanner({Map<String, dynamic>? tripToEdit}) async {
    // Se for editar, precisamos buscar os ITENS dessa viagem antes de abrir
    Map<String, dynamic>? fullTripData;
    
    if (tripToEdit != null) {
      try {
        // Busca os itens da viagem no banco
        final itemsResponse = await _supabase
            .from('trip_items')
            .select()
            .eq('trip_id', tripToEdit['id']);
            
        final itemsList = (itemsResponse as List).map((item) {
          return {
            'id': item['id'],
            'name': item['name'],
            'category': item['category'],
            'price': (item['price'] as num).toDouble(),
            'discount': (item['discount'] as num).toDouble(),
            'qty': item['qty'] ?? 1,
            // Recupera o ícone pelo código salvo
            'icon': IconData(item['icon_code'] ?? 57563, fontFamily: 'MaterialIcons'),
          };
        }).toList();

        fullTripData = {
          ...tripToEdit,
          'items': itemsList,
        };
      } catch (e) {
        debugPrint("Erro ao carregar itens: $e");
      }
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripPlannerPage(tripToEdit: fullTripData),
      ),
    );

    // Se voltou com 'true', significa que salvou algo, então recarrega tudo
    if (result == true) {
      _fetchTrips();
      _showSnackBar("Roteiro atualizado com sucesso!", icon: Icons.check_circle);
    }
  }

  void _deleteTrip(String id) async {
    try {
      await _supabase.from('trips').delete().eq('id', id);
      
      setState(() {
        _myTrips.removeWhere((t) => t['id'] == id);
      });
      _showSnackBar("Roteiro removido.", icon: Icons.delete_outline);
    } catch (e) {
      _showSnackBar("Erro ao remover.", icon: Icons.error);
    }
  }

  void _showSnackBar(String msg, {IconData icon = Icons.info_outline}) {
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
            Expanded(child: Text(msg, style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 14))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(FontAwesomeIcons.planeDeparture, color: AppColors.white, size: 32),
              const SizedBox(height: 16),
              const Text(
                "Planeje com\na NexTrip",
                style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
              ),
              const SizedBox(height: 8),
              const Text(
                "Organize suas viagens e veja a economia VIP.",
                style: TextStyle(color: AppColors.chineseWhite, fontSize: 14),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("MEUS ROTEIROS", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                  Icon(Icons.history, color: AppColors.chineseWhite, size: 18),
                ],
              ),
              const SizedBox(height: 16),

              // LISTA DE VIAGENS
              Expanded(
                child: _isLoading 
                  ? Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 40))
                  : _myTrips.isEmpty
                      ? const Center(child: Text("Nenhuma viagem planejada.\nClique em 'Criar Nova'!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _myTrips.length,
                          itemBuilder: (context, index) {
                            return _buildTripCard(_myTrips[index]);
                          },
                        ),
              ),

              // Botão Criar Novo
              GestureDetector(
                onTap: () => _openTripPlanner(), 
                child: Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.eerieBlack,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.nightRider),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_circle_outline, color: AppColors.white, size: 28),
                      SizedBox(width: 12),
                      Text("CRIAR NOVA VIAGEM", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> trip) {
    final start = trip['startDate'] as DateTime;
    final end = trip['endDate'] as DateTime;
    final dateStr = "${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}";

    return GestureDetector(
      onTap: () => _openTripPlanner(tripToEdit: trip),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip['destination'], 
                    style: const TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  
                  const SizedBox(height: 8),
                  Text(
                    "Custo: R\$ ${trip['totalCost'].toStringAsFixed(0)}",
                    style: TextStyle(color: AppColors.black.withOpacity(0.7), fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Botão de Deletar
                GestureDetector(
                  onTap: () => _deleteTrip(trip['id']),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.transparent, // Aumenta área de toque
                    child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  ),
                ),
                const SizedBox(height: 4),
                const Text("Economia", style: TextStyle(color: Colors.grey, fontSize: 10)),
                Text(
                  "R\$ ${trip['totalSavings'].toStringAsFixed(0)}", 
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}