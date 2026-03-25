import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/animal.dart';
import '../../../services/animal_service.dart';
import '../../../widgets/animal/animal_form.dart';
import '../widgets/dashboard_alerts_section.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/dashboard_kpi_row.dart';

class DashboardTab extends StatelessWidget {
  final void Function(int) onGoToTab;
  const DashboardTab({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width < 600 ? 12.0 : 24.0;
    final verticalPadding = width < 600 ? 12.0 : 20.0;
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
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(
                onRefresh: () => context.read<AnimalService>().loadData(),
                onAddAnimal: openAnimalForm,
              ),
              SizedBox(height: width < 600 ? 16 : 24),
              DashboardQuickActions(onGoToTab: onGoToTab),
              SizedBox(height: width < 600 ? 24 : 32),
              DashboardAlertsSection(onGoToTab: onGoToTab),
              SizedBox(height: width < 600 ? 24 : 32),
              DashboardKpiRow(stats: stats),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width < 600 ? 12.0 : 24.0;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 20),
      child: const Center(
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
