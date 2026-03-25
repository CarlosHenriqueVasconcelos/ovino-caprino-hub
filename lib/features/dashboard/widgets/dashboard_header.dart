import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback onRefresh;
  final VoidCallback onAddAnimal;

  const DashboardHeader({
    super.key,
    required this.onRefresh,
    required this.onAddAnimal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isCompact = width < 700;
          final isMedium = width >= 700 && width < 1050;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.06),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 12 : 20),
              child: isCompact
                  ? _buildCompactLayout(context, theme)
                  : isMedium
                      ? _buildMediumLayout(context, theme)
                      : _buildLargeLayout(context, theme),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBrandChip(theme, compact: true),
            const SizedBox(width: 10),
            Expanded(child: _buildTitleBlock(theme, compact: true)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text(
                  'Atualizar',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onAddAnimal,
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Novo Animal',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediumLayout(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBrandChip(theme),
            const SizedBox(width: 14),
            Expanded(child: _buildTitleBlock(theme)),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Recarregar dados'),
            ),
            ElevatedButton.icon(
              onPressed: onAddAnimal,
              icon: const Icon(Icons.add),
              label: const Text('Novo Animal'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeLayout(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        _buildBrandChip(theme),
        const SizedBox(width: 16),
        Expanded(child: _buildTitleBlock(theme)),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Recarregar dados'),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: onAddAnimal,
          icon: const Icon(Icons.add),
          label: const Text('Novo Animal'),
        ),
      ],
    );
  }

  Widget _buildBrandChip(ThemeData theme, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🐑', style: TextStyle(fontSize: compact ? 16 : 20)),
          SizedBox(width: compact ? 3 : 4),
          Icon(
            Icons.agriculture,
            color: Colors.white,
            size: compact ? 16 : 20,
          ),
          SizedBox(width: compact ? 3 : 4),
          Text('🐐', style: TextStyle(fontSize: compact ? 16 : 20)),
        ],
      ),
    );
  }

  Widget _buildTitleBlock(ThemeData theme, {bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fazenda São Petronio',
          style: (compact ? theme.textTheme.titleMedium : theme.textTheme.headlineSmall)
              ?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          'Sistema completo de gestão para Ovinocultura e Caprinocultura',
          style: (compact ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)
              ?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
          ),
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
