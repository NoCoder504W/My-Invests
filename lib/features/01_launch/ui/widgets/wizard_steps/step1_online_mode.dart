// lib/features/01_launch/ui/widgets/wizard_steps/step1_online_mode.dart
// Étape 1 : Choix d'activation du mode en ligne

import 'package:flutter/material.dart';

class Step1OnlineMode extends StatelessWidget {
  final bool enableOnlineMode;
  final ValueChanged<bool> onChanged;

  const Step1OnlineMode({
    super.key,
    required this.enableOnlineMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Bienvenue ! 👋',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'Configurons ensemble votre portefeuille d\'investissement.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          // Card Mode en ligne
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cloud_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Mode en ligne',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Description du mode en ligne
                  Text(
                    'Souhaitez-vous activer le mode en ligne ?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    'Le mode en ligne vous permet de :',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Liste des avantages
                  _buildFeature(context, '✓ Synchroniser automatiquement les prix de vos actifs'),
                  _buildFeature(context, '✓ Rechercher facilement des tickers lors de l\'ajout d\'actifs'),
                  _buildFeature(context, '✓ Obtenir des informations à jour sur vos investissements'),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Vous pourrez toujours modifier ce paramètre plus tard dans les réglages.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Switch
                  SwitchListTile.adaptive(
                    value: enableOnlineMode,
                    onChanged: onChanged,
                    title: Text(
                      enableOnlineMode ? 'Mode en ligne activé' : 'Mode hors ligne',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      enableOnlineMode
                          ? 'Les prix seront synchronisés automatiquement'
                          : 'Vous devrez saisir les prix manuellement',
                    ),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Note informative
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cette configuration vous guidera à travers 5 étapes pour mettre en place votre portefeuille initial.',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
