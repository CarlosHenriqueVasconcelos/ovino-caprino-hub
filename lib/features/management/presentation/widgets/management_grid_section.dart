import 'package:flutter/material.dart';

import '../../../../shared/widgets/common/section_header.dart';
import '../../../../theme/app_spacing.dart';
import 'management_module_card.dart';

class ManagementGridSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ManagementModuleItem> modules;
  final String selectedKey;
  final ValueChanged<String> onOpenModule;

  const ManagementGridSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.modules,
    required this.selectedKey,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1100 ? 3 : (width >= 700 ? 2 : 1);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: columns == 1 ? 2.4 : 1.6,
              ),
              itemBuilder: (context, index) {
                final module = modules[index];
                return ManagementModuleCard(
                  module: module,
                  selected: module.key == selectedKey,
                  onOpen: onOpenModule,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

