import 'package:flutter/material.dart';

/// Screen is considered a tablet when its shorter side is >= 600 dp.
bool isTablet(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.shortestSide >= 600;
}

/// Largeur maximale du contenu sur grand écran (liste, détail…).
const double kMaxContentWidth = 720;

/// Enveloppe un widget dans une contrainte de largeur max centrée.
/// Utilisé pour éviter que les listes ne s'étirent sur toute la largeur tablette.
Widget maxWidthBox({required Widget child, double maxWidth = kMaxContentWidth}) {
  return Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
