import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:portefeuille/core/data/models/transaction.dart';
import 'package:portefeuille/core/data/services/api_service.dart';
import 'package:portefeuille/features/00_app/providers/portfolio_provider.dart';
import 'package:portefeuille/features/00_app/providers/settings_provider.dart';
import 'package:portefeuille/features/00_app/providers/transaction_provider.dart';
import 'package:portefeuille/features/07_management/ui/providers/transaction_form_state.dart';
import 'transaction_form_ui.dart';

class TransactionFormBody extends StatelessWidget {
  final Transaction? existingTransaction;

  const TransactionFormBody({super.key, this.existingTransaction});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => TransactionFormState(
        existingTransaction: existingTransaction,
        apiService: ctx.read<ApiService>(),
        settingsProvider: ctx.read<SettingsProvider>(),
        portfolioProvider: ctx.read<PortfolioProvider>(),
        transactionProvider: ctx.read<TransactionProvider>(),
      ),
      child: const TransactionFormUI(),
    );
  }
}