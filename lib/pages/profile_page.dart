import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme/app_colors.dart';
import '../components/profile_header.dart';
import '../components/custom_button.dart';
import '../components/subscription_management_modal.dart'; // Import do Modal de Gestão
import 'login_page.dart';
import 'subscription_page.dart';
import 'all_favorite_stores_page.dart';
import 'all_favorite_deals_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final bool isVip;
  final Function(bool) onVipStatusChanged;

  const ProfilePage({
    super.key,
    required this.isVip,
    required this.onVipStatusChanged,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;
  
  // Stream que vai "ouvir" as mudanças no perfil em tempo real
  late final Stream<List<Map<String, dynamic>>> _profileStream;
  
  // Futuro para carregar as estatísticas (que não precisam ser tão realtime quanto o status VIP)
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _setupRealtime();
  }

  void _setupRealtime() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // 1. Configura o Stream do Perfil (Escuta a tabela 'profiles' pelo ID do usuário)
    _profileStream = _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id);

    // 2. Configura a busca de estatísticas (Viagens e Economia)
    _statsFuture = _fetchStats(user.id);
  }

  Future<Map<String, dynamic>> _fetchStats(String userId) async {
    final tripsData = await _supabase
        .from('trips')
        .select('total_savings')
        .eq('user_id', userId);

    double savings = 0.0;
    int count = 0;

    if (tripsData != null) {
      final list = List<Map<String, dynamic>>.from(tripsData);
      count = list.length;
      for (var t in list) {
        savings += (t['total_savings'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return {'count': count, 'savings': savings};
  }

  // --- LÓGICA DE CANCELAMENTO ---
  Future<void> _cancelSubscription() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Atualiza o banco para remover o VIP
      await _supabase.from('profiles').update({
        'is_vip': false,
        // Aqui futuramente você pode adicionar lógica de 'subscription_end_date'
        // para manter o VIP até o fim do mês pago. Por enquanto, cancela na hora.
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Assinatura cancelada. Sentiremos sua falta!"),
            backgroundColor: AppColors.white, // Branco pra manter o estilo
          ),
        );
      }
    } catch (e) {
      debugPrint("Erro ao cancelar: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erro ao cancelar assinatura."), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica autenticação antes de renderizar
    if (_supabase.auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()));
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        // STREAM BUILDER: O coração do Realtime
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _profileStream,
          builder: (context, snapshot) {
            // Loading inicial
            if (!snapshot.hasData) {
              return Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 40));
            }

            // Pega os dados do perfil (o Stream retorna uma Lista, pegamos o primeiro)
            final profile = snapshot.data!.first;
            final isVip = profile['is_vip'] ?? false;

            // Sincroniza com o pai (HomePage) se mudou o status
            // Usamos addPostFrameCallback para evitar erro de build
            if (isVip != widget.isVip) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onVipStatusChanged(isVip);
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Meu Perfil",
                    style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 24),

                  // Header agora usa dados realtime do 'profile'
                  ProfileHeader(
                    fullName: profile['full_name'] ?? "Usuário",
                    email: profile['email'] ?? "...",
                    isVip: isVip,
                    avatarUrl: profile['avatar_url'],
                  ),

                  const SizedBox(height: 32),

                  // FutureBuilder para as estatísticas (Viagens/Economia)
                  FutureBuilder<Map<String, dynamic>>(
                    future: _statsFuture,
                    builder: (context, statSnapshot) {
                      final stats = statSnapshot.data ?? {'count': 0, 'savings': 0.0};
                      return Row(
                        children: [
                          _buildStatCard("Viagens", "${stats['count']}", Icons.flight_takeoff),
                          const SizedBox(width: 16),
                          _buildStatCard("Economia", "R\$ ${stats['savings'].toStringAsFixed(0)}", Icons.savings, isGreen: true),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                  const Text("CONFIGURAÇÕES", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 16),

                  // --- BOTÃO DE ASSINATURA INTELIGENTE ---
                  _buildMenuItem(
                    icon: Icons.card_membership,
                    // Muda o texto dependendo se é VIP ou não
                    text: isVip ? "Gerenciar Assinatura" : "Seja VIP Agora",
                    isHighlight: !isVip, // Destaca se NÃO for VIP
                    onTap: () {
                       if (isVip) {
                         // Se JÁ É VIP, abre modal de gerenciamento/cancelamento
                         showModalBottomSheet(
                           context: context,
                           isScrollControlled: true,
                           backgroundColor: Colors.transparent,
                           builder: (context) => SubscriptionManagementModal(
                             onCancelSubscription: _cancelSubscription, // Passa a função de cancelar
                           ),
                         );
                       } else {
                         // Se NÃO É VIP, vai pra tela de compra
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
                       }
                    },
                  ),
                  
                  _buildMenuItem(
                    icon: Icons.store, 
                    text: "Lojas Favoritas", 
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AllFavoriteStoresPage(stores: [])));
                    }
                  ),

                  _buildMenuItem(
                    icon: Icons.local_offer_outlined, 
                    text: "Promoções Favoritas", 
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => const AllFavoriteDealsPage(deals: [])));
                    }
                  ),
                  
                  _buildMenuItem(
                    icon: Icons.settings_outlined, 
                    text: "Dados da Conta", 
                    onTap: () {
                       // Passa o perfil atual (que veio do stream) para edição
                       Navigator.push(
                         context, 
                         MaterialPageRoute(builder: (context) => EditProfilePage(currentProfile: profile))
                       );
                    }
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'SAIR DA CONTA',
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onPressed: _handleLogout,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  const Center(
                    child: Text("Versão 1.0.0", style: TextStyle(color: AppColors.nightRider, fontSize: 12)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, {bool isGreen = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.eerieBlack,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isGreen ? Colors.greenAccent : AppColors.white, size: 24),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: isGreen ? Colors.greenAccent : AppColors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.chineseWhite, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({required IconData icon, required String text, required VoidCallback onTap, bool isHighlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isHighlight ? AppColors.white : AppColors.eerieBlack,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isHighlight ? AppColors.black : AppColors.white, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: isHighlight ? AppColors.black : AppColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: isHighlight ? AppColors.black : AppColors.nightRider, size: 20),
          ],
        ),
      ),
    );
  }
}