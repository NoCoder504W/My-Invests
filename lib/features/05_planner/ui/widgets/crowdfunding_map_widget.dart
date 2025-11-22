import 'package:flutter/material.dart';
import 'package:portefeuille/core/ui/theme/app_colors.dart';
import 'package:portefeuille/core/ui/theme/app_dimens.dart';
import 'package:portefeuille/core/ui/theme/app_typography.dart';

class CrowdfundingMapWidget extends StatelessWidget {
  const CrowdfundingMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder pour la future intégration de la carte
    // Nécessite un package comme google_maps_flutter ou flutter_map
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
          child: Text(
            "Carte des Projets (Bientôt)",
            style: AppTypography.h3,
          ),
        ),
        const SizedBox(height: AppDimens.paddingM),
        Container(
          height: 200,
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 8),
              Text(
                "Visualisation géographique à venir",
                style: AppTypography.body,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
