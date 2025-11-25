import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_v7_web/theme/app_colors.dart';
import 'package:app_v7_web/components/custom_button.dart';

class RateModal extends StatefulWidget {
  final String storeId;
  final String storeName;
  final VoidCallback onReviewSubmitted;

  const RateModal({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.onReviewSubmitted,
  });

  @override
  State<RateModal> createState() => _RateModalState();
}

class _RateModalState extends State<RateModal> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecione as estrelas!")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      // Se não tiver usuário logado, usa um ID fake ou nulo (depende da sua policy no banco)
      // Idealmente, obrigue o login antes.
      
      final userName = user?.userMetadata?['full_name'] ?? 'Anônimo';

      await Supabase.instance.client.from('reviews').insert({
        'store_id': widget.storeId,
        'user_id': user?.id, 
        'user_name': userName, 
        'rating': _rating,
        'comment': _commentController.text,
      });

      if (mounted) {
        widget.onReviewSubmitted();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avaliação enviada!")));
      }
    } catch (e) {
      debugPrint("Erro review: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erro ao enviar.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppColors.eerieBlack,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Avaliar ${widget.storeName}", style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
              );
            }),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _commentController,
            style: const TextStyle(color: AppColors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Escreva sua experiência...",
              hintStyle: TextStyle(color: AppColors.chineseWhite.withOpacity(0.5)),
              filled: true,
              fillColor: AppColors.black,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'ENVIAR AVALIAÇÃO',
              isLoading: _isLoading,
              onPressed: _submitReview,
            ),
          )
        ],
      ),
    );
  }
}