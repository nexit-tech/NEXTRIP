import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../custom_search_bar.dart';

class HomeAppBar extends StatelessWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onFilterTap;
  final bool isCalculatingLocation;

  const HomeAppBar({
    super.key,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.isCalculatingLocation,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.black,
      floating: true,
      pinned: true,
      elevation: 0,
      toolbarHeight: 80,
      title: CustomSearchBar(
        onChanged: onSearchChanged,
        onFilterTap: onFilterTap,
      ),
      centerTitle: true,
      // Mostra loading line se estiver calculando GPS
      bottom: isCalculatingLocation
          ? const PreferredSize(
              preferredSize: Size.fromHeight(2),
              child: LinearProgressIndicator(
                  color: AppColors.white,
                  backgroundColor: AppColors.eerieBlack),
            )
          : null,
    );
  }
}