// lib/features/03_overview/ui/widgets/institution_list.dart
// REMPLACEZ LE FICHIER COMPLET

import 'package:flutter/material.dart';
import 'package:portefeuille/core/data/models/institution.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'account_tile.dart';
import 'package:portefeuille/features/07_management/ui/screens/add_account_screen.dart';

class InstitutionList extends StatelessWidget {
  final List<Institution> institutions;
  final bool isReadOnly; // <--- NOUVEAU

  const InstitutionList({
    super.key,
    required this.institutions,
    this.isReadOnly = false, // <--- NOUVEAU (valeur par défaut)
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: institutions.length,
      itemBuilder: (context, index) {
        final institution = institutions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8.0),
          child: ExpansionTile(
            title: Text(
              institution.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              CurrencyFormatter.format(institution.totalValue),
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              ...institution.accounts.map((account) {
                return AccountTile(account: account);
              }).toList(),

              // --- MODIFICATION ---
              // N'affiche le bouton que si nous ne sommes PAS en lecture seule
              if (!isReadOnly)
                ListTile(
                  leading: Icon(Icons.add, color: Colors.grey[400]),
                  title: Text(
                    'Ajouter un compte',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) =>
                          AddAccountScreen(institutionId: institution.id),
                    );
                  },
                ),
              // --- FIN MODIFICATION ---
            ],
          ),
        );
      },
    );
  }
}