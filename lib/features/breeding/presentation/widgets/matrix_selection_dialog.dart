import 'package:flutter/material.dart';

import '../../../../shared/widgets/common/app_card.dart';
import '../../../../shared/widgets/common/section_header.dart';
import '../../../../theme/app_spacing.dart';
import '../matrix_selection_tab.dart';

class MatrixSelectionDialog extends StatelessWidget {
  const MatrixSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = size.width < 900 ? size.width * 0.95 : 980.0;
    final dialogHeight = size.height < 700 ? size.height * 0.9 : 760.0;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: AppCard(
                variant: AppCardVariant.soft,
                child: SectionHeader(
                  title: 'Seleção de Matrizes',
                  subtitle: 'Avaliação e priorização de fêmeas',
                  action: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ),
            ),
            const Expanded(child: MatrixSelectionTab()),
          ],
        ),
      ),
    );
  }
}
