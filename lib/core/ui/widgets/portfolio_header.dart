// lib/core/ui/widgets/portfolio_header.dart
// Centralized PortfolioHeader widget moved from features/03_overview/ui/widgets

// ...existing code...
import 'package:flutter/material.dart';
import 'package:portefeuille/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';
import 'package:portefeuille/features/00_app/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:portefeuille/features/00_app/providers/portfolio_provider.dart';
import 'package:shimmer/shimmer.dart';

class PortfolioHeader extends StatelessWidget {
  const PortfolioHeader({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PortfolioProvider>();
    context.watch<SettingsProvider>();
    final baseCurrency = provider.currentBaseCurrency;
    final isProcessing = provider.isProcessingInBackground;

    final totalValue = provider.activePortfolioTotalValue;
    final totalPL = provider.activePortfolioTotalPL;
    final totalPLPercentage = provider.activePortfolioTotalPLPercentage;
    final annualYield = provider.activePortfolioEstimatedAnnualYield;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Valeur Totale du Portefeuille',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            if (isProcessing)
              _buildShimmer(theme)
            else
              Text(
                CurrencyFormatter.format(totalValue, baseCurrency),
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: isProcessing
                      ? _buildStatShimmer(theme)
                      : _buildStat(
                          context,
                          'Plus/Moins-value',
                          '${CurrencyFormatter.format(totalPL, baseCurrency)} (${NumberFormat.percentPattern().format(totalPLPercentage)})',
                          totalPL >= 0 ? Colors.green[400]! : Colors.red[400]!,
                        ),
                ),
                Expanded(
                  child: isProcessing
                      ? _buildStatShimmer(theme)
                      : _buildStat(
                          context,
                          'Rendement Annuel Estimé',
                          NumberFormat.percentPattern().format(annualYield),
                          Colors.deepPurple[400]!,
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surface,
      highlightColor: theme.colorScheme.surfaceContainerHighest,
      child: Container(
        width: 200,
        height: theme.textTheme.headlineMedium?.fontSize ?? 34,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildStatShimmer(ThemeData theme) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: theme.colorScheme.surface,
          highlightColor: theme.colorScheme.surfaceContainerHighest,
          child: Container(
            width: 100,
            height: theme.textTheme.bodySmall?.fontSize ?? 12,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Shimmer.fromColors(
          baseColor: theme.colorScheme.surface,
          highlightColor: theme.colorScheme.surfaceContainerHighest,
          child: Container(
            width: 130,
            height: theme.textTheme.titleMedium?.fontSize ?? 16,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(
      BuildContext context, String label, String value, Color valueColor) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[400]),
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          softWrap: true,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

