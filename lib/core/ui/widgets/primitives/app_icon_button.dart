import 'package:flutter/material.dart';

class AppIconButton extends StatefulWidget {
  final IconData icon;
  final Color? color;
  final String? tooltip;
  final VoidCallback? onPressed;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.color,
    this.tooltip,
    required this.onPressed,
    this.size = 24.0,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: IconButton(
          icon: Icon(widget.icon, size: widget.size),
          color: widget.color,
          tooltip: widget.tooltip,
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
