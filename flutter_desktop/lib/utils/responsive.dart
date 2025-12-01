import 'package:flutter/widgets.dart';

/// Helpers simples para ajustar layout em telas pequenas (celular/tablet).
class Responsive {
  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < 720;

  static bool isVeryCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < 520;
}
