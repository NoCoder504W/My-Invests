// lib/features/01_launch/ui/widgets/wizard_steps/step2_institutions.dart
// Étape 2 : Ajout des institutions financières

import 'package:flutter/material.dart';
import 'package:portefeuille/features/01_launch/data/wizard_models.dart';

class Step2Institutions extends StatefulWidget {
  final List<WizardInstitution> institutions;
  final VoidCallback onInstitutionsChanged;

  const Step2Institutions({
    super.key,
    required this.institutions,
    required this.onInstitutionsChanged,
  });

  @override
  State<Step2Institutions> createState() => _Step2InstitutionsState();
}

class _Step2InstitutionsState extends State<Step2Institutions> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addInstitution() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      widget.institutions.add(WizardInstitution(name: name));
      _nameController.clear();
      widget.onInstitutionsChanged();
    }
  }

  void _removeInstitution(int index) {
    widget.institutions.removeAt(index);
    widget.onInstitutionsChanged();
  }

  void _editInstitution(int index) {
    _nameController.text = widget.institutions[index].name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'institution'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nom de l\'institution',
            hintText: 'Ex: Boursorama, Binance...',
          ),
          autofocus: true,
          onSubmitted: (_) {
            widget.institutions[index].name = _nameController.text.trim();
            _nameController.clear();
            Navigator.of(context).pop();
            widget.onInstitutionsChanged();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nameController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.institutions[index].name = _nameController.text.trim();
              _nameController.clear();
              Navigator.of(context).pop();
              widget.onInstitutionsChanged();
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            'Établissements financiers 🏦',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Ajoutez les établissements où vous détenez vos comptes (banques, courtiers, plateformes crypto, etc.)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 24),

          // Formulaire d'ajout
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajouter une institution',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l\'institution',
                      hintText: 'Ex: Boursorama, Binance, Degiro...',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addInstitution(),
                  ),
                  const SizedBox(height: 12),
                  
                  ElevatedButton.icon(
                    onPressed: _addInstitution,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Liste des institutions ajoutées
          if (widget.institutions.isNotEmpty) ...[
            Text(
              'Institutions ajoutées (${widget.institutions.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.institutions.length,
              itemBuilder: (context, index) {
                final institution = widget.institutions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
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
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editInstitution(index),
                          tooltip: 'Modifier',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _removeInstitution(index),
                          tooltip: 'Supprimer',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.business_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Aucune institution ajoutée',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ajoutez au moins une institution pour continuer',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
