import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool withShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.withShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(AppDimens.paddingM),
      decoration: BoxDecoration(
        // Si une couleur est forcée, on l'utilise, sinon on utilise le dégradé par défaut
        color: backgroundColor,
        gradient: backgroundColor == null ? AppColors.surfaceGradient : null,

        borderRadius: BorderRadius.circular(AppDimens.radiusM),

        // Bordure subtile effet "verre"
        border: Border.all(color: AppColors.border, width: 1),

        // Ombre portée diffuse
        boxShadow: withShadow
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          child: content,
        ),
      );
    }

    return content;
  }
}