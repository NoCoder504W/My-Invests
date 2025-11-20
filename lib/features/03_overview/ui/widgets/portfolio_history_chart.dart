import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:portefeuille/features/00_app/providers/portfolio_provider.dart';
import 'package:portefeuille/core/data/models/portfolio_value_history_point.dart';

class PortfolioHistoryChart extends StatefulWidget {
  const PortfolioHistoryChart({super.key});

  @override
  State<PortfolioHistoryChart> createState() => _PortfolioHistoryChartState();
}

class _PortfolioHistoryChartState extends State<PortfolioHistoryChart> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        final history = provider.activePortfolio?.valueHistory ?? [];
        // Récupération de la devise dynamique (ex: "EUR", "USD")
        final currencyCode = provider.currentBaseCurrency;

        if (history.isEmpty) {
          return _buildPlaceholder(theme, "Pas encore d'historique disponible.");
        }

        // Cas particulier : un seul point, on ne peut pas tracer une ligne,
        // mais on évite le crash en affichant quand même le placeholder ou un point
        if (history.length < 2) {
          return _buildPlaceholder(theme, "Données insuffisantes pour le graphique.");
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                'Évolution du Portefeuille',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            AspectRatio(
              aspectRatio: 1.70,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18.0,
                  left: 12.0,
                  top: 24,
                  bottom: 12,
                ),
                child: LineChart(
                  _mainData(context, history, theme, currencyCode),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaceholder(ThemeData theme, String message) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  LineChartData _mainData(
      BuildContext context,
      List<PortfolioValueHistoryPoint> history,
      ThemeData theme,
      String currencyCode
      ) {
    // 1. Tri des données par date
    history.sort((a, b) => a.date.compareTo(b.date));

    final spots = history.map((point) {
      return FlSpot(
        point.date.millisecondsSinceEpoch.toDouble(),
        point.value,
      );
    }).toList();

    // 2. Calcul des échelles (Min/Max)
    double minY = history.map((e) => e.value).reduce((curr, next) => curr < next ? curr : next);
    double maxY = history.map((e) => e.value).reduce((curr, next) => curr > next ? curr : next);

    // Ajout d'une marge de 5% pour que la courbe ne touche pas les bords
    final double margin = (maxY - minY) * 0.05;
    if (margin == 0) {
      // Cas où la valeur est constante
      minY = minY * 0.9;
      maxY = maxY * 1.1;
    } else {
      minY -= margin;
      maxY += margin;
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4, // ~4 lignes horizontales
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _calculateDateInterval(history),
            getTitlesWidget: (value, meta) {
              // Évite d'afficher le dernier label s'il est trop proche du bord
              if (value == spots.last.x && spots.length > 1) return const SizedBox.shrink();

              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat('dd/MM').format(date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 45, // Espace pour "1.5M"
            interval: (maxY - minY) / 4,
            getTitlesWidget: (value, meta) {
              // Format compact pour l'axe Y (ex: 10k, 1.5M)
              return Text(
                NumberFormat.compact().format(value),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: spots.first.x,
      maxX: spots.last.x,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: theme.colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.25),
                theme.colorScheme.primary.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      // Configuration de l'infobulle (Tooltip) au toucher
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => theme.colorScheme.surfaceContainerHighest,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final date = DateTime.fromMillisecondsSinceEpoch(touchedSpot.x.toInt());
              final value = touchedSpot.y;

              // Formatage avec la devise correcte (ex: "1 234,56 $")
              final formattedValue = NumberFormat.simpleCurrency(name: currencyCode).format(value);

              return LineTooltipItem(
                '${DateFormat('dd MMM yyyy', 'fr_FR').format(date)}\n',
                theme.textTheme.bodySmall!.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: formattedValue,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
        // Personnalisation du point sélectionné
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(color: theme.colorScheme.primary, strokeWidth: 2),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: theme.colorScheme.surface,
                    strokeWidth: 3,
                    strokeColor: theme.colorScheme.primary,
                  );
                },
              ),
            );
          }).toList();
        },
      ),
    );
  }

  double _calculateDateInterval(List<PortfolioValueHistoryPoint> history) {
    if (history.isEmpty) return 1.0;
    final diff = history.last.date.difference(history.first.date).inMilliseconds;
    if (diff == 0) return 1.0;
    // On vise environ 4 labels sur l'axe X
    return diff / 4;
  }
}