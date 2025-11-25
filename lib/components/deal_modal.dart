import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_v7_web/theme/app_colors.dart';
import 'package:app_v7_web/components/custom_button.dart';
import 'package:app_v7_web/pages/internal_map_page.dart';
import 'package:app_v7_web/components/stores/rate_modal.dart';

class DealModal extends StatefulWidget {
  final Map<String, dynamic> item;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const DealModal({
    super.key, 
    required this.item, 
    required this.isFavorite, 
    required this.onFavoriteToggle,
  });

  @override
  State<DealModal> createState() => _DealModalState();
}

class _DealModalState extends State<DealModal> {
  bool _isLoading = false;
  bool _isRedeemed = false;
  bool _isCopied = false;
  late bool _localIsFavorite;

  @override
  void initState() {
    super.initState();
    _localIsFavorite = widget.isFavorite;
  }

  void _handleRedeem() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _isLoading = false; _isRedeemed = true; });
  }

  void _copyCode() {
    Clipboard.setData(const ClipboardData(text: "#NEXTRIP25"));
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  void _handleFavoriteClick() {
    setState(() { _localIsFavorite = !_localIsFavorite; });
    widget.onFavoriteToggle();
  }

  void _openRateModal() {
    final storeId = widget.item['store_id'] ?? widget.item['id']; 
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RateModal(
        storeId: storeId,
        storeName: widget.item['store_name'] ?? 'Loja',
        onReviewSubmitted: () {},
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try { await launchUrl(url, mode: LaunchMode.externalApplication); } catch (e) { debugPrint('Erro: $urlString'); }
  }

  @override
  Widget build(BuildContext context) {
    double original = (widget.item['original_price'] as num?)?.toDouble() ?? 0.0;
    double finalPrice = (widget.item['final_price'] as num?)?.toDouble() ?? 0.0;
    double savings = original - finalPrice;
    final rawPhone = widget.item['phone'] ?? '';
    final cleanPhone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.eerieBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: AppColors.nightRider, borderRadius: BorderRadius.circular(2)))),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item['name'], style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis, maxLines: 2),
                    const SizedBox(height: 4),
                    Text(widget.item['store_name']?.toUpperCase() ?? "PARCEIRO", style: const TextStyle(color: AppColors.chineseWhite, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
              ),
              IconButton(onPressed: _handleFavoriteClick, icon: Icon(_localIsFavorite ? Icons.favorite : Icons.favorite_border, color: AppColors.white, size: 28)),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Stack(
              children: [
                Container(width: double.infinity, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: NetworkImage(widget.item['img']), fit: BoxFit.cover, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation)))),
                Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]))),
                Center(child: Text(widget.item['offer'].toString().toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.white, fontSize: 40, fontWeight: FontWeight.w900, shadows: [Shadow(blurRadius: 10, color: Colors.black)]))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.nightRider)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("De R\$ ${original.toStringAsFixed(2)}", style: TextStyle(color: AppColors.chineseWhite.withOpacity(0.6), decoration: TextDecoration.lineThrough, fontSize: 12)), Text("Por R\$ ${finalPrice.toStringAsFixed(2)}", style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w900))]),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text("Economia de R\$ ${savings.toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _isRedeemed
                ? Column(key: const ValueKey('redeemed'), children: [_buildRedeemedCard(), const SizedBox(height: 16), SizedBox(width: double.infinity, child: CustomButton(text: 'AVALIAR EXPERIÊNCIA', icon: Icons.star, backgroundColor: Colors.amber, textColor: AppColors.black, onPressed: _openRateModal))])
                : SizedBox(key: const ValueKey('button'), width: double.infinity, child: CustomButton(text: 'RESGATAR CUPOM', isLoading: _isLoading, onPressed: _handleRedeem)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _secondaryButton(icon: Icons.location_on_outlined, text: 'Como Chegar', onTap: () { if (widget.item['lat'] != null && widget.item['lng'] != null) { Navigator.push(context, MaterialPageRoute(builder: (context) => InternalMapPage(selectedStore: {'name': widget.item['store_name'], 'img': widget.item['img'], 'lat': widget.item['lat'], 'lng': widget.item['lng'], 'rating': 5.0}, allStores: []))); } else { _launchURL('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.item['address'] ?? "")}'); } })),
            const SizedBox(width: 16),
            Expanded(child: _secondaryButton(icon: FontAwesomeIcons.whatsapp, text: 'Whatsapp', onTap: () { if (cleanPhone.isNotEmpty) { _launchURL('https://wa.me/55$cleanPhone'); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Telefone indisponível"))); } })),
          ]),
        ],
      ),
    );
  }

  Widget _buildRedeemedCard() {
    return GestureDetector(
      onTap: _copyCode,
      child: Container(width: double.infinity, height: 56, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(color: _isCopied ? const Color(0xFFE0FFE0) : AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 10)]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("CÓDIGO LIBERADO", style: TextStyle(color: AppColors.black, fontSize: 10, fontWeight: FontWeight.bold)), Text("#NEXTRIP25", style: TextStyle(color: AppColors.black, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1))]), AnimatedSwitcher(duration: const Duration(milliseconds: 300), transitionBuilder: (w, a) => ScaleTransition(scale: a, child: w), child: _isCopied ? Row(key: const ValueKey('c'), children: const [Text("COPIADO!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)), SizedBox(width: 8), Icon(Icons.check_circle, color: Colors.green, size: 24)]) : Row(key: const ValueKey('n'), children: const [Text("COPIAR", style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 12)), SizedBox(width: 8), Icon(Icons.copy, color: AppColors.black, size: 20)]))])),
    );
  }

  Widget _secondaryButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, size: 18, color: AppColors.white), label: Text(text, style: const TextStyle(color: AppColors.white, fontSize: 12)), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.nightRider), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
  }
}