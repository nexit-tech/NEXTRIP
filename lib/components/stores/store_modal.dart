import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../custom_button.dart';
import '../../pages/internal_map_page.dart';

class StoreModal extends StatelessWidget {
  final Map<String, dynamic> store;
  final List<Map<String, dynamic>> allStores; // <--- Parâmetro necessário pro mapa

  const StoreModal({
    super.key, 
    required this.store,
    required this.allStores,
  });

  // Mock de avaliações
  final List<Map<String, String>> _reviews = const [
    {
      "user": "Ana Clara",
      "rating": "5",
      "comment": "Atendimento excelente e as roupas são de ótima qualidade!"
    },
    {
      "user": "Marcos Silva",
      "rating": "4",
      "comment": "Gostei muito do ambiente, mas estava um pouco cheio."
    },
    {
      "user": "Julia Costa",
      "rating": "5",
      "comment": "Melhor café da região. O desconto do app funcionou na hora!"
    },
  ];

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try { await launchUrl(url, mode: LaunchMode.externalApplication); } catch (e) { debugPrint('Erro: $urlString'); }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.eerieBlack,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Handle (Barra cinza)
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: AppColors.nightRider, borderRadius: BorderRadius.circular(2)),
                ),

                // --- 1. IDENTIDADE DA LOJA ---
                Container(
                  height: 100, width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.nightRider, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(store['img']),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  store['name'],
                  style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                // Nota e Categoria
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: AppColors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      "${store['rating'] ?? 4.5} (120 avaliações)", 
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(width: 8),
                    const Text("•", style: TextStyle(color: AppColors.chineseWhite)),
                    const SizedBox(width: 8),
                    Text(store['category'], style: const TextStyle(color: AppColors.chineseWhite)),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Localização (Restaurado)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.location_on, color: AppColors.chineseWhite, size: 14),
                    SizedBox(width: 4),
                    Text("Shopping Leblon, Piso L2", style: TextStyle(color: AppColors.chineseWhite, fontSize: 14)),
                  ],
                ),

                const SizedBox(height: 24),

                // --- 2. STATUS DE OFERTAS (BADGE RESTAURADO) ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.white, 
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    "4 OFERTAS ATIVAS",
                    style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),

                const SizedBox(height: 32),

                // --- 3. AÇÕES RÁPIDAS ---
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'WHATSAPP',
                        isOutlined: true,
                        icon: FontAwesomeIcons.whatsapp,
                        onPressed: () => _launchURL('https://wa.me/552199999999'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'COMO CHEGAR',
                        isOutlined: true,
                        icon: Icons.map_outlined,
                        onPressed: () {
                          // LÓGICA CORRETA DO MAPA
                          if (store['lat'] != null && store['lng'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InternalMapPage(
                                  selectedStore: store,
                                  allStores: allStores, // Passa a lista completa
                                ),
                              ),
                            );
                          } else {
                            _launchURL('https://www.google.com/maps/search/?api=1&query=Orla33+Steakhouse');
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Divider(color: AppColors.nightRider),
                const SizedBox(height: 24),

                // --- 4. AVALIAÇÕES (RESTAURADO) ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "ÚLTIMAS AVALIAÇÕES",
                    style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
                const SizedBox(height: 16),

                ..._reviews.map((review) => _buildReviewItem(review)),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewItem(Map<String, String> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.nightRider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.nightRider,
                    child: Text(review['user']![0], style: const TextStyle(color: AppColors.white, fontSize: 10)),
                  ),
                  const SizedBox(width: 8),
                  Text(review['user']!, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < int.parse(review['rating']!) ? Icons.star : Icons.star_border,
                  color: AppColors.white,
                  size: 12,
                )),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['comment']!,
            style: const TextStyle(color: AppColors.chineseWhite, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}