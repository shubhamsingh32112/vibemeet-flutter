import 'package:flutter/material.dart';

/// Centralized brand gradients and decorative styles used across the app.
///
/// Only brand-specific colors and gradients should live here so that
/// feature screens can consume them without redefining gradients inline.

class AppBrandGradients {
  const AppBrandGradients._();

  /// Global brand background gradient for the whole app.
  /// This is the ONLY place the background Color(0x...) values should exist.
  static const LinearGradient appBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3A164E), // deep purple highlight
      Color(0xFF1B1026), // dark purple
      Color(0xFF0F0717), // near black
    ],
    stops: [0.0, 0.45, 1.0],
  );

  /// Background gradient for the Account screen.
  static const LinearGradient accountBackground = appBackground;

  /// Soft frosted card gradient used on Account header, menu cards and logout.
  static LinearGradient get frostedCard => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
      );

  /// Gradient ring around the profile avatar on the Account screen.
  static LinearGradient get avatarRing => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.purple[300]!,
          Colors.purple[600]!,
        ],
      );

  /// Creator role pill gradient.
  static LinearGradient get creatorBadge => LinearGradient(
        colors: [
          Colors.amber[600]!,
          Colors.orange[600]!,
        ],
      );

  /// Admin role pill gradient.
  static LinearGradient get adminBadge => LinearGradient(
        colors: [
          Colors.red[600]!,
          Colors.pink[600]!,
        ],
      );

  /// Avatar carousel selected border color.
  static const Color avatarCarouselSelectedBorder = Colors.white;

  /// Avatar carousel unselected border color.
  static Color get avatarCarouselUnselectedBorder =>
      Colors.white.withOpacity(0.4);

  /// Avatar carousel selected border width.
  static const double avatarCarouselSelectedBorderWidth = 3.0;

  /// Avatar carousel unselected border width.
  static const double avatarCarouselUnselectedBorderWidth = 1.5;

  /// Avatar carousel glow for the selected avatar.
  static const BoxShadow avatarCarouselGlow = BoxShadow(
    color: Colors.white24,
    blurRadius: 18,
    spreadRadius: 4,
  );

  /// Background gradient for the Wallet screen.
  static const LinearGradient walletBackground = appBackground;

  /// Wallet promo banner gradient.
  static const LinearGradient walletPromoBanner = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4F74FF),
      Color(0xFF1F2F87),
    ],
  );

  /// Wallet scaffold background (legacy; prefer transparent scaffold + [appBackground]).
  static const Color walletScaffoldBackground = Color(0xFF130818);

  /// Wallet refresh indicator background.
  static const Color walletRefreshIndicatorBackground = Color(0xFF4F74FF);

  /// Gold gradient used for coin/earnings accent.
  static const LinearGradient walletCoinGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFD65A),
      Color(0xFFFFA800),
    ],
  );

  /// Promo banner decorative icon color.
  static const Color walletPromoIcon = Color(0xFFFFC857);

  /// Highlight text color used in earnings rows (gold).
  static const Color walletEarningsHighlight = Color(0xFFFFD65A);

  /// Text color used on top of the gold coin gradient.
  static const Color walletOnGold = Colors.white;

  /// Subtle dark overlay for user cards to improve text readability on images.
  ///
  /// IMPORTANT: Do not define this gradient inline in feature screens.
  /// Use this helper and pass the current [ColorScheme].
  static LinearGradient userCardOverlay(ColorScheme scheme) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          scheme.surface.withValues(alpha: 0.0),
          scheme.surface.withValues(alpha: 0.85),
        ],
      );
}
