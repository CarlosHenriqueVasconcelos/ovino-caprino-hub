import 'package:flutter/material.dart';

/// Utilitários para responsividade consistente em todo o app
class ResponsiveUtils {
  // Breakpoints do sistema
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  // Checkers de dispositivo
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isMobileOrTablet(BuildContext context) {
    return MediaQuery.of(context).size.width < desktop;
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
    final width = MediaQuery.of(context).size.width;
    if (width < mobile) return 1;
    if (width < tablet) return 2;
    if (width < desktop) return 3;
    return 4;
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
    final width = MediaQuery.of(context).size.width;
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
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}
