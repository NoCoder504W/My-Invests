// lib/features/07_management/ui/screens/add_account_screen.dart
// REMPLACEZ LE FICHIER COMPLET

import 'package:flutter/material.dart';
import 'package:portefeuille/core/data/models/account.dart';
import 'package:portefeuille/core/data/models/account_type.dart';
import 'package:portefeuille/features/00_app/providers/portfolio_provider.dart';
// ▼▼▼ CORRECTION : Faute de frappe dans le chemin ▼▼▼
import 'package:provider/provider.dart';
// ▲▲▲ FIN CORRECTION ▲▲▲
import 'package:uuid/uuid.dart';

class AddAccountScreen extends StatefulWidget {
  final String institutionId;
  final Account? accountToEdit;
  final void Function(Account)? onAccountCreated;

  const AddAccountScreen({
    super.key,
    required this.institutionId,
    this.accountToEdit,
    this.onAccountCreated,
  });
  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  AccountType _selectedType = AccountType.cto;
  String _selectedCurrency = 'EUR';
  final _uuid = const Uuid();

  final List<String> _currencies = ['EUR', 'USD', 'CHF', 'GBP', 'CAD', 'JPY'];

  bool get _isEditing => widget.accountToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final account = widget.accountToEdit!;
      _nameController.text = account.name;
      _selectedType = account.type;
      _selectedCurrency = account.currency ?? 'EUR';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PortfolioProvider>(context, listen: false);

      if (_isEditing) {
        // --- Mode Édition ---
        // ▼▼▼ CORRECTION : On crée un NOUVEL objet Account ▼▼▼
        final oldAccount = widget.accountToEdit!;

        // 1. On crée le nouvel objet avec les champs 'final' (du constructeur)
        final updatedAccount = Account(
          id: oldAccount.id, // On garde l'ID existant
          name: _nameController.text, // Nouveau nom
          type: _selectedType, // Nouveau type
          currency: oldAccount.currency, // Devise non modifiable
        );

        // 2. On recopie manuellement les champs non-final
        //    (qui sont gérés par le repository)
        updatedAccount.assets = oldAccount.assets;
        updatedAccount.transactions = oldAccount.transactions;
        // ▲▲▲ FIN CORRECTION ▲▲▲

        provider.updateAccount(widget.institutionId, updatedAccount);

      } else {
        // --- Mode Création (logique existante) ---
        final newAccount = Account(
          id: _uuid.v4(),
          name: _nameController.text,
          type: _selectedType,
          currency: _selectedCurrency,
        );

        if (widget.onAccountCreated != null) {
          widget.onAccountCreated!(newAccount);
        } else {
          provider.addAccount(widget.institutionId, newAccount);
        }
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: keyboardPadding + 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isEditing ? 'Modifier le Compte' : 'Ajouter un Compte',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nom du compte (ex: PEA, CTO)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AccountType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type de compte',
                  border: OutlineInputBorder(),
                ),
                items: AccountType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (type) {
                  setState(() {
                    if (type != null) {
                      _selectedType = type;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Devise du compte',
                  border: const OutlineInputBorder(),
                  // ▼▼▼ CORRECTION : Remplacement de 'disabledHint' par 'hint' ▼▼▼
                  hint: _isEditing
                      ? const Text('Devise (non modifiable après création)')
                      : null,
                  // ▲▲▲ FIN CORRECTION ▲▲▲
                ),
                items: _currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: _isEditing
                    ? null // Désactive le dropdown si on édite
                    : (currency) {
                  setState(() {
                    if (currency != null) {
                      _selectedCurrency = currency;
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
              )
            ],
          ),
        ),
      ),
    );
  }
}