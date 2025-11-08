// lib/features/07_management/ui/screens/add_institution_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:portefeuille/core/data/models/institution.dart';
import 'package:portefeuille/features/00_app/providers/portfolio_provider.dart';

class AddInstitutionScreen extends StatefulWidget {
  /// Si onInstitutionCreated est fourni, l'institution sera retournée via ce callback
  /// au lieu d'être ajoutée directement au provider (utile pour l'onglet Correction)
  final void Function(Institution)? onInstitutionCreated;
  
  const AddInstitutionScreen({
    super.key,
    this.onInstitutionCreated,
  });

  @override
  State<AddInstitutionScreen> createState() => _AddInstitutionScreenState();
}

class _AddInstitutionScreenState extends State<AddInstitutionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newInstitution = Institution(
        id: _uuid.v4(),
        name: _nameController.text,
        accounts: [],
      );

      // Si un callback est fourni, on retourne l'institution
      // Sinon, on l'ajoute directement au provider
      if (widget.onInstitutionCreated != null) {
        widget.onInstitutionCreated!(newInstitution);
      } else {
        Provider.of<PortfolioProvider>(context, listen: false)
            .addInstitution(newInstitution);
      }

      // On ferme le bottom sheet
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // On ajoute un padding qui respecte le clavier
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    // MODIFIÉ : Retrait du Scaffold, ajout du SingleChildScrollView
    return SingleChildScrollView(
      child: Padding(
        // Padding global + padding pour le clavier
        padding: EdgeInsets.only(
          top: 16.0,
          left: 16.0,
          right: 16.0,
          bottom: keyboardPadding + 16.0,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important pour le bottom sheet
            children: [
              Text(
                'Ajouter une Institution',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                autofocus: true, // Ouvre le clavier directement
                decoration: const InputDecoration(
                  labelText: "Nom de l'institution",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Enregistrer'),
              )
            ],
          ),
        ),
      ),
    );
  }
}