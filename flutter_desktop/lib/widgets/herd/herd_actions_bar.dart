import 'package:flutter/material.dart';

class HerdActionsBar extends StatelessWidget {
  final VoidCallback onAddAnimal;

  const HerdActionsBar({
    super.key,
    required this.onAddAnimal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          'Rebanho',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: onAddAnimal,
          icon: const Icon(Icons.add),
          label: const Text('Adicionar Animal'),
        ),
      ],
    );
  }
}

