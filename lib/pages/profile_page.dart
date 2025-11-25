import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../theme/app_colors.dart';
import '../components/profile_header.dart';
import '../components/custom_button.dart';
import 'login_page.dart';
import 'subscription_page.dart';

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
  bool _isLoading = true;
  
  Map<String, dynamic>? _profile;
  int _tripsCount = 0;
  double _totalSavings = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;
      
      // VERIFICAÇÃO 1: Usuário está logado?
      if (session == null || user == null) {
        print("DEBUG: Usuário não logado. Redirecionando...");
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
        return;
      }

      print("DEBUG: Buscando perfil para ID: ${user.id}");

      // 1. Busca Perfil (Tenta buscar, se não achar, não quebra)
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle(); 

      // 2. Busca Estatísticas (Verifica se a coluna existe)
      final tripsData = await _supabase
          .from('trips')
          .select('total_savings')
          .eq('user_id', user.id); // Filtra só as viagens desse usuário!

      int count = 0;
      double savings = 0.0;
      
      if (tripsData != null) {
        final list = List<Map<String, dynamic>>.from(tripsData);
        count = list.length;
        for (var t in list) {
          // Proteção contra valor nulo no banco
          savings += (t['total_savings'] as num?)?.toDouble() ?? 0.0;
        }
      }

      if (mounted) {
        setState(() {
          // Se não achou perfil no banco, cria um "falso" na memória para exibir
          _profile = profileData ?? {
            'full_name': user.userMetadata?['full_name'] ?? 'Viajante',
            'email': user.email,
            'is_vip': false,
            'avatar_url': null,
          };
          
          _tripsCount = count;
          _totalSavings = savings;
          _isLoading = false;
          
          // Sincroniza VIP
          if (_profile?['is_vip'] == true && !widget.isVip) {
            widget.onVipStatusChanged(true);
          }
        });
      }
    } catch (e) {
      debugPrint("ERRO CRÍTICO NO PERFIL: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao carregar dados: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.black,
        body: Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.white, size: 40)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Meu Perfil",
                style: TextStyle(color: AppColors.white, fontSize: 32, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 24),

              ProfileHeader(
                fullName: _profile?['full_name'] ?? "Usuário",
                email: _profile?['email'] ?? "...",
                isVip: widget.isVip,
                avatarUrl: _profile?['avatar_url'],
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  _buildStatCard("Viagens", "$_tripsCount", Icons.flight_takeoff),
                  const SizedBox(width: 16),
                  _buildStatCard("Economia", "R\$ ${_totalSavings.toStringAsFixed(0)}", Icons.savings, isGreen: true),
                ],
              ),

              const SizedBox(height: 40),
              const Text("CONFIGURAÇÕES", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 16),

              _buildMenuItem(
                icon: Icons.card_membership,
                text: widget.isVip ? "Gerenciar Assinatura" : "Seja VIP Agora",
                isHighlight: !widget.isVip,
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
                },
              ),
              
              _buildMenuItem(icon: Icons.favorite_border, text: "Meus Favoritos", onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Em breve!")));
              }),
              
              _buildMenuItem(icon: Icons.settings_outlined, text: "Dados da Conta", onTap: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Em breve!")));
              }),

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