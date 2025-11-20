import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AppScreen extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool withSafeArea;

  const AppScreen({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.withSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    // Structure de base
    Widget content = Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      extendBody: true, // Permet au contenu de passer sous la navbar si elle est transparente
    );

    // Gestion sécurisée des encoches (iPhone)
    if (withSafeArea) {
      return Container(
        color: AppColors.background,
        child: SafeArea(
          bottom: false, // On laisse le bas pour la nav bar
          child: content,
        ),
      );
    }

    return content;
  }
}