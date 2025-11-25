import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../components/profile_header.dart';
import '../components/savings_card.dart';
import '../components/favorite_tile.dart';
import '../components/custom_button.dart';
import 'login_page.dart';
import 'subscription_page.dart';
import '../components/subscription_management_modal.dart';
import 'all_favorite_stores_page.dart';
import 'all_favorite_deals_page.dart';
import '../components/stores/store_modal.dart';
import '../components/deal_modal.dart';

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
  String _userName = 'Nathan Rodrigues Cardoso';
  String _userEmail = 'gabriel@monochromia.com';

  // --- DADOS ---
  final List<Map<String, dynamic>> _favStores = [
    {
      'name': 'Outback', 'category': 'Gastronomia', 'rating': 4.8, 
      'img': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9820, 'lng': -43.2177 
    },
    {
      'name': 'Nike Store', 'category': 'Moda', 'rating': 4.9,
      'img': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?q=80&w=500&auto=format&fit=crop',
      'lat': -23.0005, 'lng': -43.3315 
    },
    {
      'name': 'Zara', 'category': 'Moda', 'rating': 4.7,
      'img': 'https://images.unsplash.com/photo-1445205170230-053b83016050?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9515, 'lng': -43.1845 
    },
    {
      'name': 'Apple', 'category': 'Tech', 'rating': 5.0,
      'img': 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9997, 'lng': -43.3505 
    },
  ];

  final List<Map<String, dynamic>> _favDeals = [
    {
      'name': 'Burger King', 'offer': 'Combo 50% OFF', 'location': 'Centro',
      'img': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9035, 'lng': -43.1735 
    },
    {
      'name': 'Hotel Ibis', 'offer': 'R\$ 80,00 OFF', 'location': 'Copacabana',
      'img': 'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9698, 'lng': -43.1869 
    },
    {
      'name': 'Adidas', 'offer': 'Tênis 30% OFF', 'location': 'Barra Shopping',
      'img': 'https://images.unsplash.com/photo-1511556532299-8f662fc26c06?q=80&w=500&auto=format&fit=crop',
      'lat': -22.9230, 'lng': -43.2350 
    },
  ];

  void _showSnackBar(String msg, {IconData icon = Icons.info_outline}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  void _showEditProfileModal() {
    final nameController = TextEditingController(text: _userName);
    final emailController = TextEditingController(text: _userEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        decoration: const BoxDecoration(color: AppColors.eerieBlack, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Editar Perfil", style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildTextField("Nome", nameController),
            const SizedBox(height: 16),
            _buildTextField("Email", emailController),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: CustomButton(text: 'SALVAR ALTERAÇÕES', onPressed: (){ 
                setState(() { _userName = nameController.text; _userEmail = emailController.text; });
                Navigator.pop(context);
                _showSnackBar("Perfil atualizado!", icon: Icons.check_circle);
            }))
          ],
        ),
      )
    );
  }

  void _handlePhotoClick() { _showSnackBar("Abrir galeria de fotos...", icon: Icons.camera_alt); }
  void _handleLogout() { Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false); }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.nightRider)),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(controller: controller, style: const TextStyle(color: AppColors.white), decoration: const InputDecoration(border: InputBorder.none)),
        )
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewMore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        GestureDetector(
          onTap: onViewMore,
          child: const Text("Ver mais", style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: ProfileHeader(name: _userName, email: _userEmail, imageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=500&auto=format&fit=crop', onEditTap: _showEditProfileModal, onPhotoTap: _handlePhotoClick)),
              
              const SizedBox(height: 40),
              const SavingsCard(amount: 350.00),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: widget.isVip ? 'GERENCIAR ASSINATURA' : 'SEJA VIP AGORA',
                  isOutlined: true,
                  textColor: widget.isVip ? Colors.greenAccent : AppColors.white,
                  icon: FontAwesomeIcons.crown,
                  onPressed: () async {
                    if (!widget.isVip) {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const SubscriptionPage()));
                      if (result == true) {
                        widget.onVipStatusChanged(true);
                        _showSnackBar("Bem-vindo ao Clube VIP!", icon: FontAwesomeIcons.crown);
                      }
                    } else {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SubscriptionManagementModal(
                          onCancelSubscription: () {
                            widget.onVipStatusChanged(false);
                            _showSnackBar("Assinatura cancelada. Sentiremos sua falta!", icon: Icons.sentiment_dissatisfied);
                          },
                        ),
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 40),

              // --- 1. LOJAS PREFERIDAS ---
              _buildSectionHeader("LOJAS PREFERIDAS", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllFavoriteStoresPage(stores: _favStores)));
              }),
              const SizedBox(height: 16),
              // CORREÇÃO AQUI: Passando 'allStores: _favStores'
              ..._favStores.take(3).map((item) => FavoriteTile(
                item: item,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => StoreModal(
                      store: item, 
                      allStores: _favStores // <--- CORREÇÃO
                    ),
                  );
                },
              )).toList(),

              const SizedBox(height: 40),

              // --- 2. PROMOÇÕES PREFERIDAS ---
              _buildSectionHeader("PROMOÇÕES PREFERIDAS", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllFavoriteDealsPage(deals: _favDeals)));
              }),
              const SizedBox(height: 16),
              ..._favDeals.take(3).map((item) => FavoriteTile(
                item: item,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => DealModal(
                      item: item,
                      isFavorite: true,
                      onFavoriteToggle: () {}, 
                    ),
                  );
                },
              )).toList(),

              const SizedBox(height: 40),
              
              SizedBox(width: double.infinity, child: CustomButton(text: 'ALTERAR SENHA', isOutlined: true, icon: Icons.lock_outline, onPressed: () => _showSnackBar("Email de redefinição enviado!", icon: Icons.email))),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: CustomButton(text: 'SAIR DA CONTA', isOutlined: true, icon: Icons.logout, onPressed: _handleLogout)),
              
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    Text("Versão 1.0.0", style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5), fontSize: 10)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Powered by ", style: TextStyle(color: AppColors.chineseWhite, fontSize: 12)),
                        Text("NEXIT", style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}