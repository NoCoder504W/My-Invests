import 'package:flutter/material.dart';
import 'package:portefeuille/core/ui/theme/app_colors.dart';
import 'package:portefeuille/core/ui/theme/app_dimens.dart';
import 'package:portefeuille/core/ui/theme/app_typography.dart';
import 'package:portefeuille/core/ui/widgets/primitives/app_card.dart';
import 'package:portefeuille/features/04_journal/ui/models/transaction_sort_option.dart';

class TransactionFilterBar extends StatelessWidget {
  final TransactionSortOption sortOption;
  final ValueChanged<TransactionSortOption> onSortChanged;
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onDeleteSelected;
  final VoidCallback onCancelSelection;

  const TransactionFilterBar({
    super.key,
    required this.sortOption,
    required this.onSortChanged,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onDeleteSelected,
    required this.onCancelSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (isSelectionMode) ...[
              Text('$selectedCount sélectionné(s)', style: AppTypography.bodyBold),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.select_all, color: AppColors.primary),
                    onPressed: onSelectAll,
                    tooltip: 'Tout sélectionner',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: onDeleteSelected,
                    tooltip: 'Supprimer la sélection',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onCancelSelection,
                    tooltip: 'Annuler',
                  ),
                ],
              ),
            ] else ...[
              Text('Trier par', style: AppTypography.body),
              DropdownButtonHideUnderline(
                child: DropdownButton<TransactionSortOption>(
                  value: sortOption,
                  dropdownColor: AppColors.surfaceLight,
                  icon: const Icon(Icons.sort, color: AppColors.primary),
                  style: AppTypography.bodyBold,
                  items: const [
                    DropdownMenuItem(value: TransactionSortOption.dateDesc, child: Text('Date (Récent)')),
                    DropdownMenuItem(value: TransactionSortOption.dateAsc, child: Text('Date (Ancien)')),
                    DropdownMenuItem(value: TransactionSortOption.amountDesc, child: Text('Montant (Haut)')),
                    DropdownMenuItem(value: TransactionSortOption.amountAsc, child: Text('Montant (Bas)')),
                    DropdownMenuItem(value: TransactionSortOption.type, child: Text('Type')),
                    DropdownMenuItem(value: TransactionSortOption.institution, child: Text('Institution')),
                    DropdownMenuItem(value: TransactionSortOption.account, child: Text('Compte')),
                  ],
                  onChanged: (value) {
                    if (value != null) onSortChanged(value);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
