// lib/features/01_launch/ui/widgets/wizard_steps/step3_accounts.dart
// Étape 3 : Ajout des comptes pour chaque institution

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:portefeuille/features/01_launch/data/wizard_models.dart';
import 'package:portefeuille/core/data/models/account_type.dart';

class Step3Accounts extends StatefulWidget {
  final List<WizardInstitution> institutions;
  final List<WizardAccount> accounts;
  final VoidCallback onAccountsChanged;

  const Step3Accounts({
    super.key,
    required this.institutions,
    required this.accounts,
    required this.onAccountsChanged,
  });

  @override
  State<Step3Accounts> createState() => _Step3AccountsState();
}

class _Step3AccountsState extends State<Step3Accounts> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cashBalanceController = TextEditingController();
  WizardInstitution? _selectedInstitution;
  AccountType _selectedType = AccountType.pea;

  @override
  void initState() {
    super.initState();
    if (widget.institutions.isNotEmpty) {
      _selectedInstitution = widget.institutions.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cashBalanceController.dispose();
    super.dispose();
  }

  void _addAccount() {
    final name = _nameController.text.trim();
    final cashBalanceStr = _cashBalanceController.text.trim();
    
    if (name.isEmpty || _selectedInstitution == null) {
      return;
    }

    final cashBalance = double.tryParse(cashBalanceStr) ?? 0.0;

    final account = WizardAccount(
      name: name,
      type: _selectedType,
      institutionName: _selectedInstitution!.name,
      cashBalance: cashBalance,
    );

    widget.accounts.add(account);
    _selectedInstitution!.accounts.add(account);
    
    _nameController.clear();
    _cashBalanceController.clear();
    widget.onAccountsChanged();
  }

  void _removeAccount(int index) {
    final account = widget.accounts[index];
    
    // Retirer aussi de l'institution parente
    final institution = widget.institutions.firstWhere(
      (i) => i.name == account.institutionName,
    );
    institution.accounts.remove(account);
    
    widget.accounts.removeAt(index);
    widget.onAccountsChanged();
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
            'Comptes 💳',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Ajoutez vos comptes d\'investissement pour chaque institution',
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
                    'Ajouter un compte',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Sélection de l'institution
                  DropdownButtonFormField<WizardInstitution>(
                    value: _selectedInstitution,
                    decoration: const InputDecoration(
                      labelText: 'Institution',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    items: widget.institutions.map((institution) {
                      return DropdownMenuItem(
                        value: institution,
                        child: Text(institution.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedInstitution = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Nom du compte
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du compte',
                      hintText: 'Ex: PEA Principal, CTO Crypto...',
                      prefixIcon: Icon(Icons.account_balance),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Type de compte
                  DropdownButtonFormField<AccountType>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type de compte',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: AccountType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getAccountTypeLabel(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedType = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Solde de liquidités initial
                  TextField(
                    controller: _cashBalanceController,
                    decoration: const InputDecoration(
                      labelText: 'Solde de liquidités actuel (€)',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.euro),
                      border: OutlineInputBorder(),
                      helperText: 'Le solde de liquidités disponible sur ce compte',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ElevatedButton.icon(
                    onPressed: _addAccount,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter le compte'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Liste des comptes ajoutés
          if (widget.accounts.isNotEmpty) ...[
            Text(
              'Comptes ajoutés (${widget.accounts.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.accounts.length,
              itemBuilder: (context, index) {
                final account = widget.accounts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: Icon(
                        _getAccountTypeIcon(account.type),
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    title: Text(
                      account.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${account.institutionName} • ${_getAccountTypeLabel(account.type)} • ${account.cashBalance.toStringAsFixed(2)}€',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () => _removeAccount(index),
                      tooltip: 'Supprimer',
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
                    Icon(Icons.account_balance_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Aucun compte ajouté',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ajoutez au moins un compte pour continuer',
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

  String _getAccountTypeLabel(AccountType type) {
    switch (type) {
      case AccountType.pea:
        return 'PEA';
      case AccountType.cto:
        return 'CTO';
      case AccountType.assuranceVie:
        return 'Assurance Vie';
      case AccountType.per:
        return 'PER';
      case AccountType.crypto:
        return 'Crypto';
      case AccountType.autre:
        return 'Autre';
    }
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.pea:
      case AccountType.cto:
        return Icons.trending_up;
      case AccountType.assuranceVie:
        return Icons.security;
      case AccountType.per:
        return Icons.savings;
      case AccountType.crypto:
        return Icons.currency_bitcoin;
      case AccountType.autre:
        return Icons.account_balance_wallet;
    }
  }
}
