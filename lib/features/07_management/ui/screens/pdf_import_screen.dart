import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:portefeuille/features/07_management/services/pdf_import_service.dart';
import 'package:portefeuille/features/07_management/services/pdf/statement_parser.dart';
import 'package:portefeuille/core/ui/theme/app_dimens.dart';
import 'package:portefeuille/core/ui/theme/app_colors.dart';
import 'package:portefeuille/core/ui/theme/app_typography.dart';
import 'package:portefeuille/core/ui/widgets/primitives/app_button.dart';
import 'package:portefeuille/features/00_app/providers/portfolio_provider.dart';
import 'package:portefeuille/core/data/models/account.dart';
import 'package:portefeuille/core/data/models/transaction.dart';

class PdfImportScreen extends StatefulWidget {
  const PdfImportScreen({super.key});

  @override
  State<PdfImportScreen> createState() => _PdfImportScreenState();
}

class _PdfImportScreenState extends State<PdfImportScreen> {
  final _pdfService = PdfImportService();
  final _uuid = const Uuid();
  
  List<ParsedTransaction> _extractedTransactions = [];
  bool _isLoading = false;
  String? _fileName;
  Account? _selectedAccount;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _isLoading = true;
        _fileName = result.files.single.name;
      });

      final file = File(result.files.single.path!);
      final transactions = await _pdfService.extractTransactions(file);

      setState(() {
        _extractedTransactions = transactions;
        _isLoading = false;
      });
    }
  }

  void _removeTransaction(int index) {
    setState(() {
      _extractedTransactions.removeAt(index);
    });
  }

  void _editTransaction(int index) {
    final tx = _extractedTransactions[index];
    final nameController = TextEditingController(text: tx.assetName);
    final tickerController = TextEditingController(text: tx.ticker);
    final qtyController = TextEditingController(text: tx.quantity.toString());
    final priceController = TextEditingController(text: tx.price.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier la transaction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom de l\'actif'),
              ),
              TextField(
                controller: tickerController,
                decoration: const InputDecoration(labelText: 'Ticker (ex: AAPL)'),
              ),
              TextField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Quantité'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Prix unitaire'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _extractedTransactions[index] = ParsedTransaction(
                  date: tx.date,
                  type: tx.type,
                  assetName: nameController.text,
                  ticker: tickerController.text.isEmpty ? null : tickerController.text,
                  quantity: double.tryParse(qtyController.text) ?? tx.quantity,
                  price: double.tryParse(priceController.text) ?? tx.price,
                  amount: (double.tryParse(qtyController.text) ?? tx.quantity) * 
                          (double.tryParse(priceController.text) ?? tx.price),
                  fees: tx.fees,
                  currency: tx.currency,
                  isin: tx.isin,
                );
              });
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _validateImport() async {
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un compte')),
      );
      return;
    }

    final provider = Provider.of<PortfolioProvider>(context, listen: false);
    int count = 0;

    for (final parsed in _extractedTransactions) {
      // Conversion ParsedTransaction -> Transaction
      final transaction = Transaction(
        id: _uuid.v4(),
        accountId: _selectedAccount!.id,
        type: parsed.type,
        date: parsed.date,
        assetTicker: parsed.ticker ?? parsed.assetName, // Fallback ticker
        assetName: parsed.assetName,
        quantity: parsed.quantity,
        price: parsed.price,
        amount: parsed.amount,
        fees: parsed.fees,
        notes: "Import PDF: $_fileName",
        assetType: null, // TODO: Infer asset type
        priceCurrency: parsed.currency,
      );

      await provider.addTransaction(transaction);
      count++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count transactions importées avec succès')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PortfolioProvider>(context);
    // Flatten all accounts from all institutions in the active portfolio
    final accounts = provider.activePortfolio?.institutions
        .expand((inst) => inst.accounts)
        .toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Import PDF')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Account Selection
            DropdownButtonFormField<Account>(
              decoration: const InputDecoration(
                labelText: 'Compte de destination',
                border: OutlineInputBorder(),
              ),
              value: _selectedAccount,
              items: accounts.map((account) {
                return DropdownMenuItem(
                  value: account,
                  child: Text(account.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccount = value;
                });
              },
            ),
            const SizedBox(height: AppDimens.paddingL),

            // 2. File Picker
            if (_fileName == null)
              AppButton(
                label: 'Sélectionner un PDF',
                onPressed: _pickPdf,
                icon: Icons.upload_file,
              )
            else
              Row(
                children: [
                  const Icon(Icons.description, color: AppColors.primary),
                  const SizedBox(width: AppDimens.paddingS),
                  Expanded(child: Text(_fileName!, style: AppTypography.bodyBold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _fileName = null;
                        _extractedTransactions = [];
                      });
                    },
                  )
                ],
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(AppDimens.paddingL),
                child: Center(child: CircularProgressIndicator()),
              ),
            
            const SizedBox(height: AppDimens.paddingL),
            
            // 3. Preview List
            Expanded(
              child: _extractedTransactions.isEmpty
                  ? Center(
                      child: Text(
                        _fileName == null 
                          ? "Sélectionnez un fichier pour commencer" 
                          : "Aucune transaction trouvée",
                        style: AppTypography.body,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _extractedTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = _extractedTransactions[index];
                        final isReady = tx.ticker != null || tx.assetName.isNotEmpty;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppDimens.paddingS),
                          child: ListTile(
                            leading: Icon(
                              isReady ? Icons.check_circle : Icons.warning,
                              color: isReady ? Colors.green : Colors.orange,
                            ),
                            title: Text(tx.assetName),
                            subtitle: Text(
                              '${tx.type.name} • ${tx.quantity} x ${tx.price} ${tx.currency}\n${tx.date.toString().split(' ')[0]}',
                              style: AppTypography.caption,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editTransaction(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeTransaction(index),
                                ),
                              ],
                            ),
                            onTap: () => _editTransaction(index),
                          ),
                        );
                      },
                    ),
            ),

            // 4. Validation Button
            if (_extractedTransactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppDimens.paddingL),
                child: AppButton(
                  label: 'Importer ${_extractedTransactions.length} transactions',
                  onPressed: _validateImport,
                  icon: Icons.check,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
