import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized gradient definitions for the Vibrant Light theme.
class AppGradients {
  // ── Primary Brand Gradient ───────────────────────────────────────────────
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradStart, AppColors.gradEnd],
  );

  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.gradStart, AppColors.gradEnd],
  );

  static const LinearGradient primarySoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF8B82FF), Color(0xFF00D4B4)],
    stops: [0.0, 0.5, 1.0],
  );

  // ── Background Gradient ──────────────────────────────────────────────────
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F9FE), Color(0xFFEEF2FF), Color(0xFFF8F9FE)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient darkHeader = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF4A42CC)],
  );

  // ── Card & Surface Gradients ─────────────────────────────────────────────
  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white, Color(0xFFFAFAFF)],
  );

  static const LinearGradient glassCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFAAAAAA), Color(0xFFFFFFFF)],
  );

  // ── Metric Card Gradients ────────────────────────────────────────────────
  static const LinearGradient metricBlue = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
  );

  static const LinearGradient metricPurple = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  );

  static const LinearGradient metricTeal = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient metricOrange = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );

  // ── Status Gradients ─────────────────────────────────────────────────────
  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient error = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFA3E635), Color(0xFF65A30D)],
  );

  static const LinearGradient info = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
  );

  // ── Hero Banner Gradient ─────────────────────────────────────────────────
  static const LinearGradient heroBanner = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF4A42CC), Color(0xFF00D4B4)],
  );

  // ── Shimmer Loading Gradient ─────────────────────────────────────────────
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    colors: [
      Color(0xFFE2E8F0),
      Color(0xFFF1F5F9),
      Color(0xFFE2E8F0),
    ],
    stops: [0.1, 0.5, 0.9],
  );

  // ── Image Overlay Gradients ─────────────────────────────────────────────
  static const LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x990F172A),
    ],
    stops: [0.5, 1.0],
  );

  static const LinearGradient imageOverlayTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x80000000),
      Colors.transparent,
    ],
  );
}
