import 'package:flutter/material.dart';
import 'package:portefeuille/core/ui/theme/app_colors.dart';
import 'package:portefeuille/core/ui/theme/app_typography.dart';
import 'package:portefeuille/core/ui/widgets/components/app_screen.dart';
import 'package:portefeuille/features/07_management/ui/screens/add_transaction_screen.dart';

class ImportHubScreen extends StatelessWidget {
  const ImportHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Ajouter une transaction', style: AppTypography.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Comment souhaitez-vous ajouter vos données ?',
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _buildOptionCard(
                context,
                title: 'Saisie Manuelle',
                description: 'Ajouter une transaction unitaire rapidement.',
                icon: Icons.edit_note,
                color: AppColors.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildOptionCard(
                context,
                title: 'Importer un Fichier',
                description: 'Relevés bancaires (PDF), Exports (CSV, Excel)...',
                icon: Icons.upload_file,
                color: AppColors.accent,
                onTap: () {
                  // TODO: Navigate to FileImportWizard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Assistant d\'import bientôt disponible')),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.surfaceGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48, color: color),
                ),
                const SizedBox(height: 16),
                Text(title, style: AppTypography.h2),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
