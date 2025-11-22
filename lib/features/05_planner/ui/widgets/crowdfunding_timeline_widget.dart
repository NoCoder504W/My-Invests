import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:portefeuille/core/data/models/asset.dart';
import 'package:portefeuille/core/data/models/asset_type.dart';
import 'package:portefeuille/core/data/models/transaction_type.dart';
import 'package:portefeuille/core/ui/theme/app_colors.dart';
import 'package:portefeuille/core/ui/theme/app_dimens.dart';
import 'package:portefeuille/core/ui/theme/app_typography.dart';
import 'package:portefeuille/features/00_app/providers/portfolio_provider.dart';

class CrowdfundingTimelineWidget extends StatelessWidget {
  const CrowdfundingTimelineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PortfolioProvider>();
    final portfolio = provider.activePortfolio;
    
    if (portfolio == null) return const SizedBox.shrink();

    // Collecter les projets avec leur plateforme (Institution)
    final List<Map<String, dynamic>> items = [];
    for (var institution in portfolio.institutions) {
      for (var account in institution.accounts) {
        for (var asset in account.assets) {
          if (asset.type == AssetType.RealEstateCrowdfunding && asset.quantity > 0) {
            items.add({
              'asset': asset,
              'platform': institution.name,
            });
          }
        }
      }
    }

    if (items.isEmpty) return const SizedBox.shrink();

    // Trier par date de fin estimée
    items.sort((a, b) {
      final assetA = a['asset'] as Asset;
      final assetB = b['asset'] as Asset;
      final endA = _getEndDate(assetA);
      final endB = _getEndDate(assetB);
      return endA.compareTo(endB);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingL),
          child: Text(
            "Calendrier des Projets",
            style: AppTypography.h3,
          ),
        ),
        const SizedBox(height: AppDimens.paddingM),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final asset = item['asset'] as Asset;
            final platformName = item['platform'] as String;
            
            final startDate = _getStartDate(asset);
            final endDate = _getEndDate(asset);
            final now = DateTime.now();
            
            final totalDuration = endDate.difference(startDate).inDays;
            final elapsed = now.difference(startDate).inDays;
            final progress = (totalDuration > 0) ? (elapsed / totalDuration).clamp(0.0, 1.0) : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: AppDimens.paddingS),
              padding: const EdgeInsets.all(AppDimens.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          asset.name,
                          style: AppTypography.bodyBold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        DateFormat('MMM yyyy', 'fr_FR').format(endDate),
                        style: AppTypography.caption.copyWith(
                          color: endDate.isBefore(now) ? AppColors.error : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.background,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        endDate.isBefore(now) ? AppColors.error : AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        platformName,
                        style: AppTypography.caption,
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  DateTime _getStartDate(Asset asset) {
    final buyTransactions = asset.transactions
        .where((t) => t.type == TransactionType.Buy)
        .toList();
    if (buyTransactions.isEmpty) return DateTime.now();
    buyTransactions.sort((a, b) => a.date.compareTo(b.date));
    return buyTransactions.first.date;
  }

  DateTime _getEndDate(Asset asset) {
    final start = _getStartDate(asset);
    final duration = asset.targetDuration ?? 0;
    return start.add(Duration(days: duration * 30));
  }
}
