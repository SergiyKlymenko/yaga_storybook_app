import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MagicButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget? icon; // icon — тепер необов’язковий
  final String label;
  final TextStyle textStyle;
  final double width;
  final double height;
  final double spacing; // відстань між іконкою та текстом

  const MagicButton({
    super.key,
    required this.onPressed,
    this.icon,
    required this.label,
    required this.textStyle,
    required this.width,
    required this.height,
    this.spacing = 18,
  });

  @override
  State<MagicButton> createState() => _MagicButtonState();
}

class _MagicButtonState extends State<MagicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFA500),
                  Color(0xFFFFD700),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(_glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  SizedBox(width: widget.spacing),
                ],
                Text(
                  widget.label,
                  style: widget.textStyle,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
