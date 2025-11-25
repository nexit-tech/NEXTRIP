import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final bool isVip;
  final String? avatarUrl;

  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.email,
    required this.isVip,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Pega as iniciais para o avatar (Ex: "Gabriel Dev" -> "GD")
    String initials = "U";
    if (fullName.isNotEmpty) {
      List<String> names = fullName.trim().split(" ");
      if (names.length >= 2) {
        initials = "${names[0][0]}${names[1][0]}".toUpperCase();
      } else {
        initials = names[0][0].toUpperCase();
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.eerieBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.nightRider),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isVip ? Colors.amber : AppColors.nightRider, // Borda Dourada se VIP
              border: Border.all(
                color: isVip ? Colors.amber : Colors.transparent,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0), // Espaço entre borda e foto
              child: CircleAvatar(
                backgroundColor: AppColors.black,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl == null
                    ? Text(initials, style: const TextStyle(color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold))
                    : null,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        fullName,
                        style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVip) ...[
                      const SizedBox(width: 8),
                      const Icon(FontAwesomeIcons.crown, color: Colors.amber, size: 16),
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(color: AppColors.chineseWhite.withOpacity(0.7), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Badge de Status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVip ? Colors.amber.withOpacity(0.2) : AppColors.nightRider,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isVip ? Colors.amber : Colors.transparent),
                  ),
                  child: Text(
                    isVip ? "MEMBRO VIP" : "MEMBRO GRATUITO",
                    style: TextStyle(
                      color: isVip ? Colors.amber : AppColors.chineseWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}