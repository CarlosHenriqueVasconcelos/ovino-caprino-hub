import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

/// Widget que automaticamente usa Row em desktop e Wrap em mobile/tablet
/// para evitar overflows em layouts horizontais
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;
  final double runSpacing;
  final bool forceWrap;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8,
    this.runSpacing = 8,
    this.forceWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final shouldWrap = forceWrap || ResponsiveUtils.isMobileOrTablet(context);

    if (shouldWrap) {
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: _getWrapAlignment(mainAxisAlignment),
        crossAxisAlignment: _getWrapCrossAlignment(crossAxisAlignment),
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: _addSpacing(children, spacing),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;
    
    final spacedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(width: spacing));
      }
    }
    return spacedChildren;
  }

  WrapAlignment _getWrapAlignment(MainAxisAlignment alignment) {
    switch (alignment) {
      case MainAxisAlignment.start:
        return WrapAlignment.start;
      case MainAxisAlignment.end:
        return WrapAlignment.end;
      case MainAxisAlignment.center:
        return WrapAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return WrapAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return WrapAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return WrapAlignment.spaceEvenly;
    }
  }

  WrapCrossAlignment _getWrapCrossAlignment(CrossAxisAlignment alignment) {
    switch (alignment) {
      case CrossAxisAlignment.start:
        return WrapCrossAlignment.start;
      case CrossAxisAlignment.end:
        return WrapCrossAlignment.end;
      case CrossAxisAlignment.center:
        return WrapCrossAlignment.center;
      default:
        return WrapCrossAlignment.center;
    }
  }
}
