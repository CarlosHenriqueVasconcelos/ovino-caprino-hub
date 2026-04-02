import 'package:flutter/material.dart';

enum ResponsiveWidthTier { small, medium, large, extraLarge }

/// Utilitários para responsividade consistente em todo o app
class ResponsiveUtils {
  const ResponsiveUtils._();

  // Breakpoints base para layouts de página (reutilizáveis no app).
  static const double small = 360;
  static const double medium = 768;
  static const double large = 1200;

  // Breakpoints do sistema
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static double _widthOf(BuildContext context) => MediaQuery.sizeOf(context).width;

  static ResponsiveWidthTier widthTierForWidth(double width) {
    if (width < small) return ResponsiveWidthTier.small;
    if (width < medium) return ResponsiveWidthTier.medium;
    if (width < large) return ResponsiveWidthTier.large;
    return ResponsiveWidthTier.extraLarge;
  }

  static ResponsiveWidthTier widthTier(BuildContext context) {
    return widthTierForWidth(_widthOf(context));
  }

  // Checkers de dispositivo
  static bool isMobile(BuildContext context) {
    return _widthOf(context) < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = _widthOf(context);
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return _widthOf(context) >= desktop;
  }

  static bool isMobileOrTablet(BuildContext context) {
    return _widthOf(context) < desktop;
  }

  // Inset horizontal estrutural do shell (container externo).
  // Mantém 0 em telas menores para evitar compressão por padding duplicado.
  static double getShellHorizontalInset(BuildContext context) {
    return getShellHorizontalInsetForWidth(_widthOf(context));
  }

  static double getShellHorizontalInsetForWidth(double width) {
    switch (widthTierForWidth(width)) {
      case ResponsiveWidthTier.small:
      case ResponsiveWidthTier.medium:
        return 0;
      case ResponsiveWidthTier.large:
        return 8;
      case ResponsiveWidthTier.extraLarge:
        return 12;
    }
  }

  // Padding horizontal interno do conteúdo da página.
  static double getPageHorizontalPadding(BuildContext context) {
    return getPageHorizontalPaddingForWidth(_widthOf(context));
  }

  static double getPageHorizontalPaddingForWidth(double width) {
    switch (widthTierForWidth(width)) {
      case ResponsiveWidthTier.small:
        return 12;
      case ResponsiveWidthTier.medium:
        return 16;
      case ResponsiveWidthTier.large:
        return 20;
      case ResponsiveWidthTier.extraLarge:
        return 24;
    }
  }

  static double getPageVerticalPadding(BuildContext context) {
    return getPageVerticalPaddingForWidth(_widthOf(context));
  }

  static double getPageVerticalPaddingForWidth(double width) {
    switch (widthTierForWidth(width)) {
      case ResponsiveWidthTier.small:
        return 12;
      case ResponsiveWidthTier.medium:
        return 14;
      case ResponsiveWidthTier.large:
        return 18;
      case ResponsiveWidthTier.extraLarge:
        return 20;
    }
  }

  static double getCenteredMaxContentWidth(BuildContext context) {
    return getCenteredMaxContentWidthForWidth(_widthOf(context));
  }

  static double getCenteredMaxContentWidthForWidth(double width) {
    switch (widthTierForWidth(width)) {
      case ResponsiveWidthTier.small:
      case ResponsiveWidthTier.medium:
        return double.infinity;
      case ResponsiveWidthTier.large:
        return 1120;
      case ResponsiveWidthTier.extraLarge:
        return 1240;
    }
  }

  // Padding adaptativo
  static double getPadding(BuildContext context) {
    if (isMobile(context)) return 12;
    if (isTablet(context)) return 16;
    return 24;
  }

  // Espaçamento adaptativo
  static double getSpacing(BuildContext context) {
    if (isMobile(context)) return 8;
    if (isTablet(context)) return 12;
    return 16;
  }

  // Número de colunas para grids
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  // Número de colunas para formulários
  static int getFormColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  // Cross axis count para grids de animais
  static int getAnimalGridCrossAxisCount(BuildContext context) {
    return getAnimalGridCrossAxisCountForWidth(_widthOf(context));
  }

  static int getAnimalGridCrossAxisCountForWidth(double width) {
    if (width < mobile) return 1;
    if (width < tablet) return 2;
    if (width < desktop) return 3;
    return 4;
  }

  // Altura alvo do card compacto de animais por largura disponível.
  static double getAnimalCardTargetHeightForWidth(
    double width, {
    int? crossAxisCount,
  }) {
    final columns = crossAxisCount ?? getAnimalGridCrossAxisCountForWidth(width);

    if (columns <= 1) {
      if (width < 360) return 190;
      if (width < 430) return 198;
      return 205;
    }

    if (columns == 2) {
      if (width < 760) return 190;
      return 205;
    }

    if (columns == 3) {
      if (width < desktop) return 198;
      return 210;
    }

    return 214;
  }

  // Child aspect ratio para grids
  static double getCardAspectRatio(BuildContext context) {
    if (isMobile(context)) return 1.2;
    if (isTablet(context)) return 1.3;
    return 1.4;
  }

  // Font sizes adaptativas
  static double getTitleFontSize(BuildContext context) {
    if (isMobile(context)) return 20;
    if (isTablet(context)) return 22;
    return 24;
  }

  static double getBodyFontSize(BuildContext context) {
    if (isMobile(context)) return 14;
    if (isTablet(context)) return 15;
    return 16;
  }

  // Icon sizes adaptativas
  static double getIconSize(BuildContext context) {
    if (isMobile(context)) return 20;
    if (isTablet(context)) return 22;
    return 24;
  }

  // Touch target mínimo (recomendado: 48x48)
  static double get minTouchTarget => 48;

  // Dialog width adaptativa
  static double getDialogWidth(BuildContext context) {
    final width = _widthOf(context);
    if (width < mobile) return width * 0.95;
    if (width < tablet) return 500;
    if (width < desktop) return 600;
    return 700;
  }

  // Max width para conteúdo
  static double getMaxContentWidth(BuildContext context) {
    if (isMobile(context)) return double.infinity;
    if (isTablet(context)) return 800;
    return 1200;
  }

  // Verifica se deve usar layout compacto
  static bool shouldUseCompactLayout(BuildContext context) {
    return isMobile(context);
  }

  // Orientation checker
  static bool isPortrait(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }
}
