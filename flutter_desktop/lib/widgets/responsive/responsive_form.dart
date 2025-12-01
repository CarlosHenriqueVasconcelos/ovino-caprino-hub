import 'package:flutter/material.dart';
import '../../utils/responsive_utils.dart';

/// Widget para criar formulários responsivos que se adaptam ao tamanho da tela
/// - Mobile: 1 coluna
/// - Tablet: 2 colunas
/// - Desktop: 2-3 colunas (configurável)
class ResponsiveForm extends StatelessWidget {
  final List<Widget> children;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveForm({
    super.key,
    required this.children,
    this.desktopColumns,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final columns = _getColumns(context);

    if (columns == 1) {
      // Layout em coluna única
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _addVerticalSpacing(children, runSpacing),
      );
    }

    // Layout em grid multi-coluna
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.map((child) {
        return SizedBox(
          width: _getItemWidth(context, columns),
          child: child,
        );
      }).toList(),
    );
  }

  int _getColumns(BuildContext context) {
    if (ResponsiveUtils.isMobile(context)) return 1;
    if (ResponsiveUtils.isTablet(context)) return 2;
    return desktopColumns ?? 3;
  }

  double _getItemWidth(BuildContext context, int columns) {
    final width = MediaQuery.of(context).size.width;
    final totalSpacing = spacing * (columns - 1);
    return (width - totalSpacing - (ResponsiveUtils.getPadding(context) * 2)) / columns;
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
}

/// Widget para criar linha de formulário responsiva com label e campo
class ResponsiveFormField extends StatelessWidget {
  final String label;
  final Widget field;
  final bool required;

  const ResponsiveFormField({
    super.key,
    required this.label,
    required this.field,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required)
              Text(
                ' *',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
