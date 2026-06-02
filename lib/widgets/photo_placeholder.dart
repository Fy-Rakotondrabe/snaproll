import 'package:flutter/material.dart';

class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    this.width,
    this.height,
    this.color1,
    this.color2,
    this.borderRadius,
    this.label,
    this.child,
  });

  final double? width;
  final double? height;
  final Color? color1;
  final Color? color2;
  final double? borderRadius;
  final String? label;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c1 = color1 ?? const Color(0xFF1A2F6E);
    final c2 = color2 ?? const Color(0xFF0B1020);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c1, c2],
        ),
      ),
      child: child ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_rounded, color: Colors.white24, size: 28),
              if (label != null) ...[
                const SizedBox(height: 6),
                Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ],
          ),
    );
  }
}
