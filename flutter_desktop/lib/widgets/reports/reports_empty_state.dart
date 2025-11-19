import 'package:flutter/material.dart';

class ReportsEmptyState extends StatelessWidget {
  final String message;
  final Widget? action;

  const ReportsEmptyState({
    super.key,
    required this.message,
    this.action,
  });

  factory ReportsEmptyState.locked({
    required Future<bool?> Function() onUnlock,
  }) {
    return ReportsEmptyState(
      message: 'Relatório protegido. Clique para desbloquear.',
      action: ElevatedButton.icon(
        onPressed: () {
          onUnlock();
        },
        icon: const Icon(Icons.lock_open),
        label: const Text('Desbloquear'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.insights, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            action!,
          ],
        ],
      ),
    );
  }
}

