// lib/features/01_launch/ui/widgets/wizard_steps/step5_summary.dart
// Étape 5 : Récapitulatif et validation

import 'package:flutter/material.dart';
import 'package:portefeuille/features/01_launch/data/wizard_models.dart';

class Step5Summary extends StatelessWidget {
  final List<WizardInstitution> institutions;
  final List<WizardAccount> accounts;
  final List<WizardAsset> assets;
  final String portfolioName;

  const Step5Summary({
    super.key,
    required this.institutions,
    required this.accounts,
    required this.assets,
    required this.portfolioName,
  });

  @override
  Widget build(BuildContext context) {
    // Calculs pour le récapitulatif
    final totalCash = accounts.fold<double>(0, (sum, account) => sum + account.cashBalance);
    final totalAssetValue = assets.fold<double>(0, (sum, asset) => sum + asset.totalValue);
    final totalValue = totalCash + totalAssetValue;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Récapitulatif ✓',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Vérifiez les informations avant de finaliser la configuration',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 24),

          // Carte récapitulative globale
          Card(
            elevation: 4,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    portfolioName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatChip(
                        context,
                        Icons.business,
                        '${institutions.length}',
                        'Institution${institutions.length > 1 ? 's' : ''}',
                      ),
                      _buildStatChip(
                        context,
                        Icons.account_balance,
                        '${accounts.length}',
                        'Compte${accounts.length > 1 ? 's' : ''}',
                      ),
                      _buildStatChip(
                        context,
                        Icons.show_chart,
                        '${assets.length}',
                        'Actif${assets.length > 1 ? 's' : ''}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  Divider(color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Valeur totale estimée',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    '${totalValue.toStringAsFixed(2)} €',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Liquidités: ${totalCash.toStringAsFixed(2)}€ • Actifs: ${totalAssetValue.toStringAsFixed(2)}€',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Détail des institutions et comptes
          Text(
            'Détail par institution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: institutions.length,
            itemBuilder: (context, index) {
              final institution = institutions[index];
              final institutionAccounts = accounts
                  .where((a) => a.institutionName == institution.name)
                  .toList();
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      institution.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    institution.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${institutionAccounts.length} compte${institutionAccounts.length > 1 ? 's' : ''}'),
                  children: institutionAccounts.map((account) {
                    final accountAssets = assets
                        .where((a) => a.accountDisplayName == account.displayName)
                        .toList();
                    final accountTotalAssetValue = accountAssets.fold<double>(
                      0, 
                      (sum, asset) => sum + asset.totalValue,
                    );
                    final accountTotalValue = account.cashBalance + accountTotalAssetValue;
                    
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      title: Text(
                        account.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Liquidités: ${account.cashBalance.toStringAsFixed(2)}€'),
                          if (accountAssets.isNotEmpty)
                            Text('${accountAssets.length} actif${accountAssets.length > 1 ? 's' : ''}: ${accountTotalAssetValue.toStringAsFixed(2)}€'),
                        ],
                      ),
                      trailing: Text(
                        '${accountTotalValue.toStringAsFixed(2)}€',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Note informative
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prêt à finaliser',
                        style: TextStyle(
                          color: Colors.green[900],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cliquez sur "Terminer" pour créer votre portefeuille avec ces données. Vous pourrez toujours modifier ces informations plus tard.',
                        style: TextStyle(color: Colors.green[900]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
              ),
        ),
      ],
    );
  }
}
