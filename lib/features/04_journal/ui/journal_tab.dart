// lib/features/04_journal/ui/journal_tab.dart
// NOUVEAU FICHIER

import 'package:flutter/material.dart';
import 'package:portefeuille/features/04_journal/ui/views/synthese_view.dart';
import 'package:portefeuille/features/04_journal/ui/views/transactions_view.dart';

class JournalTab extends StatefulWidget {
  const JournalTab({super.key});

  @override
  State<JournalTab> createState() => _JournalTabState();
}

class _JournalTabState extends State<JournalTab>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.account_balance_outlined),
              text: 'Synthèse Actifs',
            ),
            Tab(
              icon: Icon(Icons.receipt_long_outlined),
              text: 'Transactions',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              // Étape 2 (Vue lecture seule)
              SyntheseView(),

              // Étape 3 (CRUD Transactions)
              TransactionsView(),
            ],
          ),
        ),
      ],
    );
  }
}