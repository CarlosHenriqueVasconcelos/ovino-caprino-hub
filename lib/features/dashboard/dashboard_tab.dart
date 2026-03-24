import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/animal.dart';
import '../../services/animal_service.dart';
import '../../widgets/animal/animal_form.dart';
import 'widgets/dashboard_alerts_section.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/dashboard_quick_actions.dart';
import 'widgets/dashboard_kpi_row.dart';

class DashboardTab extends StatelessWidget {
  final void Function(int) onGoToTab;
  const DashboardTab({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.select<AnimalService, bool>((service) => service.isLoading);
    final stats =
        context.select<AnimalService, AnimalStats?>((service) => service.stats);

    if (isLoading || stats == null) {
      return const _DashboardLoading();
    }

    void openAnimalForm() {
      showDialog(
        context: context,
        builder: (context) => const AnimalFormDialog(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            onRefresh: () => context.read<AnimalService>().loadData(),
            onAddAnimal: openAnimalForm,
          ),
          const SizedBox(height: 24),
          DashboardQuickActions(onGoToTab: onGoToTab),
          const SizedBox(height: 32),
          DashboardAlertsSection(onGoToTab: onGoToTab),
          const SizedBox(height: 32),
          DashboardKpiRow(stats: stats),
        ],
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando painel...'),
            ],
          ),
        ),
      ),
    );
  }
}
