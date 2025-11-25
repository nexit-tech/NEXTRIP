import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String imageUrl;
  final VoidCallback onEditTap;
  final VoidCallback onPhotoTap; // <--- Novo Callback pra foto

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.onEditTap,
    required this.onPhotoTap, // <--- Obrigatório agora
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar com borda e Botão de Foto
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.nightRider, width: 2),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(imageUrl),
                backgroundColor: AppColors.eerieBlack,
              ),
            ),
            
            // --- CORREÇÃO: BOTÃO DE FOTO CLICÁVEL ---
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onPhotoTap, // <--- Clica aqui e chama a função
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, size: 16, color: AppColors.black),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 16),
        
        // --- CORREÇÃO: PREVENIR OVERFLOW NO NOME ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Margem pra não colar na borda
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Ocupa o mínimo necessário
            children: [
              Flexible( // <--- O SEGREDO: Permite encolher se precisar
                child: Text(
                  name,
                  maxLines: 1, // Garante uma linha só
                  overflow: TextOverflow.ellipsis, // Coloca "..." se for grande
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onEditTap,
                icon: const Icon(Icons.edit, color: AppColors.chineseWhite, size: 18),
                splashRadius: 20,
                constraints: const BoxConstraints(), // Remove padding extra do botão
                padding: EdgeInsets.zero,
              )
            ],
          ),
        ),
        
        const SizedBox(height: 4),

        // Email
        Text(
          email,
          style: const TextStyle(
            color: AppColors.chineseWhite,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}