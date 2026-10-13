import 'package:flutter/material.dart';

class GoldVerifiedSealWidget extends StatelessWidget {
  final double size;
  final String label;

  const GoldVerifiedSealWidget({
    super.key,
    this.size = 84.0,
    this.label = 'ĐÃ KÝ ĐIỆN TỬ',
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.15, // Slight tilt angle for realistic stamp feel
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFF59E0B),
              Color(0xFFFBBF24),
              Color(0xFFD97706),
              Color(0xFF78350F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.85),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_rounded,
                color: Color(0xFFFBBF24),
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'VERIFIED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
