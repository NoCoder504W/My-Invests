import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:portefeuille/core/data/models/asset_type.dart';
import 'package:portefeuille/core/ui/theme/app_colors.dart';
import 'package:portefeuille/core/ui/theme/app_typography.dart';

class AssetTypeAllocationChart extends StatefulWidget {
  final Map<AssetType, double> allocationData;
  final double totalValue;

  const AssetTypeAllocationChart({
    super.key,
    required this.allocationData,
    required this.totalValue,
  });

  @override
  State<AssetTypeAllocationChart> createState() => _AssetTypeAllocationChartState();
}

class _AssetTypeAllocationChartState extends State<AssetTypeAllocationChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final bool hasData = widget.allocationData.isNotEmpty && widget.totalValue > 0;

    return Column(
      // ▼▼▼ MODIFICATION : Centrage du titre ▼▼▼
      crossAxisAlignment: CrossAxisAlignment.center,
      // ▲▲▲ FIN MODIFICATION ▲▲▲
      children: [
        Text(
          'Répartition par actifs',
          style: AppTypography.h3,
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: hasData
              ? PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: _generateSections(
                widget.allocationData,
                widget.totalValue,
              ),
              centerSpaceRadius: 60,
              sectionsSpace: 4,
              startDegreeOffset: -90,
            ),
          )
              : Center(
            child: Text(
              'Aucune donnée',
              style: AppTypography.caption,
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generateSections(
      Map<AssetType, double> allocationData,
      double totalValue,
      ) {
    if (totalValue <= 0) return [];

    final entries = allocationData.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    return List.generate(entries.length, (i) {
      final isTouched = i == touchedIndex;
      final entry = entries[i];
      final percentage = (entry.value / totalValue) * 100;
      final radius = isTouched ? 25.0 : 20.0;

      if (entry.value <= 0) return PieChartSectionData(value: 0);

      return PieChartSectionData(
        color: AppColors.charts[i % AppColors.charts.length],
        value: entry.value,
        title: '',
        radius: radius,
        badgeWidget: _buildBadge(
            entry.key.displayName,
            percentage,
            isTouched,
            AppColors.charts[i % AppColors.charts.length]
        ),
        // ▼▼▼ MODIFICATION : Écartement des étiquettes (2.2 au lieu de 1.6) ▼▼▼
        badgePositionPercentageOffset: 2.2,
        // ▲▲▲ FIN MODIFICATION ▲▲▲
      );
    }).where((section) => section.value > 0).toList();
  }

  Widget _buildBadge(String name, double percentage, bool isTouched, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isTouched ? 8 : 4),
      decoration: BoxDecoration(
        color: isTouched ? AppColors.surfaceLight : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: isTouched ? Border.all(color: color) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: AppTypography.caption.copyWith(
              color: isTouched ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: AppTypography.label.copyWith(
              color: color,
              fontSize: isTouched ? 12 : 10,
            ),
          ),
        ],
      ),
    );
  }
}