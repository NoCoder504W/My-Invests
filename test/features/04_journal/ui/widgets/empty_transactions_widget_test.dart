import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portefeuille/features/04_journal/ui/widgets/empty_transactions_widget.dart';

void main() {
  testWidgets('EmptyTransactionsWidget displays correct text and button', (WidgetTester tester) async {
    // Arrange
    bool addPressed = false;
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyTransactionsWidget(
            onAdd: () => addPressed = true,
            onImportPdf: () {},
            onImportCsv: () {},
            onImportCrowdfunding: () {},
            onImportAi: () {},
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Aucune transaction'), findsOneWidget);
    expect(find.text('Commencez par alimenter votre journal.'), findsOneWidget);
    
    // Check for Action Cards
    expect(find.text('Manuel'), findsOneWidget);
    expect(find.text('Import PDF'), findsOneWidget);
    expect(find.text('Import CSV'), findsOneWidget);
    
    // Test interaction with Manuel card
    final manualCardFinder = find.text('Manuel');
    await tester.tap(manualCardFinder);
    expect(addPressed, isTrue);
  });

  testWidgets('EmptyTransactionsWidget hides button when onAdd is null', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyTransactionsWidget(
            onAdd: null,
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Aucune transaction'), findsOneWidget);
    expect(find.text('Manuel'), findsNothing);
  });
}
