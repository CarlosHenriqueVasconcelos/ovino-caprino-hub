import 'package:flutter/material.dart';

import '../matrix_selection_tab.dart';

class MatrixSelectionDialog extends StatelessWidget {
  const MatrixSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = size.width < 900 ? size.width * 0.95 : 980.0;
    final dialogHeight = size.height < 700 ? size.height * 0.9 : 760.0;

    return Dialog(
      child: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.workspace_premium, color: Colors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Seleção de Matrizes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Expanded(child: MatrixSelectionTab()),
          ],
        ),
      ),
    );
  }
}
