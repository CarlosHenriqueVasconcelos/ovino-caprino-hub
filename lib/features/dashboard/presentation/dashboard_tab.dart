import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
	
import '../../../models/animal.dart';
import '../../../shared/widgets/animal/animal_form.dart';
import '../application/dashboard_controller.dart';
import '../data/dashboard_repository.dart';
import '../widgets/dashboard_alerts_section.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_kpi_row.dart';
import '../widgets/dashboard_overview_section.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../../../services/animal_service.dart';
import '../../../services/medication_service.dart';
import '../../../services/pharmacy_service.dart';

class DashboardTab extends StatelessWidget {
  final void Function(int) onGoToTab;
  const DashboardTab({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DashboardRepository>(
          create: (context) => DashboardRepository(
            animalService: context.read<AnimalService>(),
            pharmacyService: context.read<PharmacyService>(),
            medicationService: context.read<MedicationService>(),
          ),
        ),
        ChangeNotifierProvider<DashboardController>(
          create: (context) => DashboardController(
            dashboardRepository: context.read<DashboardRepository>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final width = MediaQuery.of(context).size.width;
          final horizontalPadding = width < 600 ? 10.0 : 22.0;
          final verticalPadding = width < 600 ? 10.0 : 18.0;
          final sectionGap = width < 600 ? 20.0 : 28.0;
          final isLoading = context.select<DashboardController, bool>(
            (controller) => controller.isLoading,
          );
          final stats = context.select<DashboardController, AnimalStats?>(
            (controller) => controller.stats,
          );

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
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardHeader(
                      onRefresh: () =>
                          context.read<DashboardController>().refresh(),
                      onAddAnimal: openAnimalForm,
                      stats: stats,
                    ),
                    SizedBox(height: sectionGap),
                    DashboardKpiRow(stats: stats),
                    SizedBox(height: sectionGap),
                    DashboardAlertsSection(onGoToTab: onGoToTab),
                    SizedBox(height: sectionGap),
                    DashboardQuickActions(onGoToTab: onGoToTab),
                    SizedBox(height: sectionGap),
                    DashboardOverviewSection(stats: stats),
                  ],
                ),
              ),
            ),
          );
        },
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
