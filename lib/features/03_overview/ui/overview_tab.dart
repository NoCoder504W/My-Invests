import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core UI
import 'package:portefeuille/core/ui/theme/app_dimens.dart';
import 'package:portefeuille/core/ui/theme/app_typography.dart';
import 'package:portefeuille/core/ui/widgets/components/app_screen.dart';
import 'package:portefeuille/core/ui/widgets/primitives/app_card.dart';
import 'package:portefeuille/core/ui/widgets/primitives/app_icon.dart';
import 'package:portefeuille/core/ui/widgets/fade_in_slide.dart';
import 'package:portefeuille/core/ui/widgets/portfolio_header.dart'; // Notre nouveau header

// Features
import '../../00_app/providers/portfolio_provider.dart';
import '../../00_app/services/modal_service.dart';
import 'package:portefeuille/features/03_overview/ui/widgets/portfolio_history_chart.dart';
import 'widgets/allocation_chart.dart';
import 'widgets/asset_type_allocation_chart.dart';
import 'widgets/sync_alerts_card.dart';
import 'package:portefeuille/features/03_overview/ui/widgets/institution_tile.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        final portfolio = portfolioProvider.activePortfolio;

        if (portfolio == null) {
          return const Center(child: Text("Aucun portefeuille sélectionné."));
        }

        final institutions = portfolio.institutions;

        // On utilise AppScreen pour avoir le fond "Midnight" automatiquement
        return AppScreen(
          withSafeArea: false, // Déjà géré par le parent (Dashboard)
          body: CustomScrollView(
            slivers: [
              // En-tête avec titre
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingL,
                      AppDimens.paddingL,
                      AppDimens.paddingL,
                      AppDimens.paddingM
                  ),
                  child: Text(
                    'Vue d\'ensemble',
                    style: AppTypography.h1,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Contenu principal
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. Header (Total)
                    FadeInSlide(
                      delay: 0.1,
                      child: const PortfolioHeader(),
                    ),
                    const SizedBox(height: AppDimens.paddingM),

                    // 2. Graphique
                    FadeInSlide(
                      delay: 0.2,
                      child: AppCard(
                        child: const PortfolioHistoryChart(),
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingM),

                    // 3. Allocations
                    FadeInSlide(
                      delay: 0.3,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Responsive layout
                          if (constraints.maxWidth >= 800) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildAllocationCard(portfolio, portfolioProvider)),
                                const SizedBox(width: AppDimens.paddingM),
                                Expanded(child: _buildAssetTypeCard(portfolioProvider)),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              _buildAllocationCard(portfolio, portfolioProvider),
                              const SizedBox(height: AppDimens.paddingM),
                              _buildAssetTypeCard(portfolioProvider),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingM),

                    // 4. Institutions (Section)
                    FadeInSlide(
                      delay: 0.4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(
                            context,
                            'Structure du Portefeuille',
                            Icons.account_balance,
                            onAdd: () => ModalService.showAddInstitution(context),
                          ),
                          const SizedBox(height: AppDimens.paddingS),

                          if (institutions.isEmpty)
                            const AppCard(
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text('Aucune institution. Ajoutez-en une pour commencer.'),
                                ),
                              ),
                            )
                          else
                            ...institutions.asMap().entries.map((entry) {
                              final index = entry.key;
                              final institution = entry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppDimens.paddingS),
                                child: InstitutionTile(institution: institution),
                              );
                            }),
                        ],
                      ),
                    ),

                    // 5. Alertes
                    const SizedBox(height: AppDimens.paddingM),
                    FadeInSlide(
                      delay: 0.5,
                      child: const SyncAlertsCard(), // À migrer plus tard vers AppCard en interne
                    ),

                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllocationCard(dynamic portfolio, PortfolioProvider provider) {
    return AppCard(
      child: AllocationChart(portfolio: portfolio),
    );
  }

  Widget _buildAssetTypeCard(PortfolioProvider provider) {
    return AppCard(
      child: AssetTypeAllocationChart(
        allocationData: provider.aggregatedValueByAssetType,
        totalValue: provider.activePortfolioTotalValue,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, {VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingXS, vertical: AppDimens.paddingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AppIcon(icon: icon, size: 18),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: AppTypography.label.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          if (onAdd != null)
            AppIcon(
              icon: Icons.add,
              onTap: onAdd,
              backgroundColor: Colors.transparent,
              size: 20,
            ),
        ],
      ),
    );
  }
}