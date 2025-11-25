import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import 'trip_planner_page.dart';

class TravelPage extends StatefulWidget {
  const TravelPage({super.key});

  @override
  State<TravelPage> createState() => _TravelPageState();
}

class _TravelPageState extends State<TravelPage> {
  
  // --- LISTA DE VIAGENS (Estado) ---
  // Começamos com 2 exemplos mockados
  final List<Map<String, dynamic>> _myTrips = [
    {
      'id': '1',
      'destination': 'Réveillon Copacabana',
      'startDate': DateTime(2025, 12, 28),
      'endDate': DateTime(2026, 1, 2),
      'items': [], // Sem itens pra simplificar o mock
      'totalCost': 4500.00,
      'totalSavings': 450.00,
    },
    {
      'id': '2',
      'destination': 'Férias Disney',
      'startDate': DateTime(2026, 7, 10),
      'endDate': DateTime(2026, 7, 20),
      'items': [],
      'totalCost': 15000.00,
      'totalSavings': 1200.00,
    },
  ];

  // Abre o planejador e espera o resultado (Salvar)
  Future<void> _openTripPlanner({Map<String, dynamic>? tripToEdit}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripPlannerPage(tripToEdit: tripToEdit)),
    );

    if (result != null) {
      setState(() {
        // Se estamos editando (já tem ID na lista), atualiza
        final index = _myTrips.indexWhere((t) => t['id'] == result['id']);
        if (index != -1) {
          _myTrips[index] = result;
        } else {
          // Se é novo, adiciona
          _myTrips.add(result);
        }
      });
      
      _showSnackBar("Roteiro salvo com sucesso!", icon: Icons.check_circle);
    }
  }

  void _deleteTrip(Map<String, dynamic> trip) {
    setState(() {
      _myTrips.remove(trip);
    });
    _showSnackBar("Roteiro removido.", icon: Icons.delete_outline);
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
        duration: const Duration(seconds: 3),
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
                child: _myTrips.isEmpty
                    ? const Center(child: Text("Nenhuma viagem planejada.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _myTrips.length,
                        itemBuilder: (context, index) {
                          return _buildTripCard(_myTrips[index]);
                        },
                      ),
              ),

              // Botão Criar Novo
              GestureDetector(
                onTap: () => _openTripPlanner(), // Cria novo
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
    // Formata datas
    final start = trip['startDate'] as DateTime;
    final end = trip['endDate'] as DateTime;
    final dateStr = "${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}";

    return GestureDetector(
      onTap: () => _openTripPlanner(tripToEdit: trip), // Abre para editar
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
                  
                  // --- NOVO: MOSTRA CUSTO TOTAL ---
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
                // Botão de Deletar discreto
                GestureDetector(
                  onTap: () => _deleteTrip(trip),
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 8.0, left: 8.0),
                    child: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  ),
                ),
                const Text("Economia", style: TextStyle(color: Colors.grey, fontSize: 10)),
                Text(
                  "R\$ ${trip['totalSavings'].toStringAsFixed(0)} off", 
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