import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';
import 'app_section_switcher.dart';

class MoreMenuSheet extends StatelessWidget {
  final List<AppSectionOption> options;
  final String selectedKey;

  const MoreMenuSheet({
    super.key,
    required this.options,
    required this.selectedKey,
  });

  static Future<String?> show(
    BuildContext context, {
    required List<AppSectionOption> options,
    required String selectedKey,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => MoreMenuSheet(
        options: options,
        selectedKey: selectedKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mais',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Acesse módulos secundários do sistema.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ...options.map(
              (option) => ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(option.icon),
                title: Text(option.label),
                trailing: option.key == selectedKey
                    ? const Icon(Icons.check_circle)
                    : null,
                onTap: () => Navigator.of(context).pop(option.key),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
