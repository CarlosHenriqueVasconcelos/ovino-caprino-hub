import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

/// Widget para ações (botões) que se adaptam ao layout
/// - Mobile: vertical, botões full-width
/// - Desktop: horizontal, botões compactos
class ResponsiveActions extends StatelessWidget {
  final List<Widget> actions;
  final MainAxisAlignment mainAxisAlignment;
  final double spacing;

  const ResponsiveActions({
    super.key,
    required this.actions,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      // Layout vertical em mobile
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _addVerticalSpacing(actions, spacing),
      );
    }

    // Layout horizontal em tablet/desktop
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: _getWrapAlignment(mainAxisAlignment),
      children: actions,
    );
  }

  List<Widget> _addVerticalSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;
    
    final spacedChildren = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
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
}

/// Botão adaptativo que muda entre icon button e text button
class ResponsiveActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const ResponsiveActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) {
      // Botão full-width em mobile
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: style,
        ),
      );
    }

    // Botão compacto em desktop
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: style,
    );
  }
}
