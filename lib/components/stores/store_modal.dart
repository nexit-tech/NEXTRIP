import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_v7_web/theme/app_colors.dart';
import 'package:app_v7_web/components/custom_button.dart';
import 'package:app_v7_web/pages/internal_map_page.dart';
// Removi o import do rate_modal.dart pois não vamos usar agora

class StoreModal extends StatefulWidget {
  final Map<String, dynamic> store;
  final List<Map<String, dynamic>> allStores;

  const StoreModal({
    super.key, 
    required this.store,
    required this.allStores,
  });

  @override
  State<StoreModal> createState() => _StoreModalState();
}

class _StoreModalState extends State<StoreModal> {
  List<Map<String, dynamic>> _lastReviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final response = await Supabase.instance.client
          .from('reviews')
          .select()
          .eq('store_id', widget.store['id'])
          .order('created_at', ascending: false)
          .limit(3);

      if (mounted) {
        setState(() {
          _lastReviews = List<Map<String, dynamic>>.from(response);
          _loadingReviews = false;
        });
      }
    } catch (e) {
      debugPrint('Erro reviews: $e');
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try { await launchUrl(url, mode: LaunchMode.externalApplication); } catch (e) { debugPrint('Erro: $urlString'); }
  }

  @override
  Widget build(BuildContext context) {
    final rawPhone = widget.store['phone'] ?? '';
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

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
                Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: AppColors.nightRider, borderRadius: BorderRadius.circular(2))),

                // Identidade
                Container(
                  height: 100, width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.nightRider, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(widget.store['img']),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(widget.store['name'], style: const TextStyle(color: AppColors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                // Nota
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.store['rating']} (${_lastReviews.isEmpty ? 'Novato' : '${_lastReviews.length} avaliações'})", 
                      style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(width: 8),
                    const Text("•", style: TextStyle(color: AppColors.chineseWhite)),
                    const SizedBox(width: 8),
                    Text(widget.store['category'] ?? '', style: const TextStyle(color: AppColors.chineseWhite)),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                if (widget.store['address'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, color: AppColors.chineseWhite, size: 14),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            widget.store['address'], 
                            style: const TextStyle(color: AppColors.chineseWhite, fontSize: 14),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(50)),
                  child: const Text("VER OFERTAS", style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),

                const SizedBox(height: 32),

                // Ações
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'WHATSAPP',
                        isOutlined: true,
                        icon: FontAwesomeIcons.whatsapp,
                        onPressed: () {
                          if (cleanPhone.isNotEmpty) {
                            _launchURL('https://wa.me/55$cleanPhone');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Telefone não disponível")));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'COMO CHEGAR',
                        isOutlined: true,
                        icon: Icons.map_outlined,
                        onPressed: () {
                          if (widget.store['lat'] != null && widget.store['lng'] != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => InternalMapPage(selectedStore: widget.store, allStores: widget.allStores)));
                          } else {
                            _launchURL('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.store['address'] ?? "")}');
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Divider(color: AppColors.nightRider),
                
                // Cabeçalho de Avaliações (SEM O BOTÃO DE AVALIAR)
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "ÚLTIMAS AVALIAÇÕES", 
                    style: TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                  ),
                ),
                const SizedBox(height: 16),

                if (_loadingReviews)
                  const Center(child: CircularProgressIndicator(color: AppColors.white))
                else if (_lastReviews.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: const Text("Essa loja ainda não tem avaliações.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  )
                else
                  ..._lastReviews.map((review) => _buildReviewItem(review)),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final date = DateTime.parse(review['created_at']);
    final dateStr = "${date.day}/${date.month}/${date.year}";

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
                    child: const Icon(Icons.person, size: 14, color: AppColors.chineseWhite),
                  ),
                  const SizedBox(width: 8),
                  Text(review['user_name'] ?? 'Anônimo', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < (review['rating'] ?? 0) ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 12,
                )),
              )
            ],
          ),
          const SizedBox(height: 8),
          if (review['comment'] != null && review['comment'].toString().isNotEmpty)
            Text(
              review['comment'],
              style: const TextStyle(color: AppColors.chineseWhite, fontSize: 13, height: 1.4),
            ),
          const SizedBox(height: 8),
          Text(dateStr, style: TextStyle(color: AppColors.chineseWhite.withOpacity(0.4), fontSize: 10)),
        ],
      ),
    );
  }
}