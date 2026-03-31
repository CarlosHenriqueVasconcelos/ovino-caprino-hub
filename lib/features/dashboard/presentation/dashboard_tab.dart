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
import '../widgets/dashboard_visual_style.dart';
import '../../../theme/app_spacing.dart';
import '../../../services/animal_service.dart';
import '../../../services/medication_service.dart';
import '../../../services/pharmacy_service.dart';
import '../../../utils/responsive_utils.dart';

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding =
              ResponsiveUtils.getPageHorizontalPaddingForWidth(width);
          final verticalPadding =
              ResponsiveUtils.getPageVerticalPaddingForWidth(width);
          final maxContentWidth =
              ResponsiveUtils.getCenteredMaxContentWidthForWidth(width);
          final sectionGap =
              DashboardVisualStyle.blockGap(width) + AppSpacing.xs;
          final isLoading = context.select<DashboardController, bool>(
            (controller) => controller.isLoading,
          );
          final stats = context.select<DashboardController, AnimalStats?>(
            (controller) => controller.stats,
          );

          if (isLoading || stats == null) {
            return _DashboardLoading(
              width: width,
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
              maxContentWidth: maxContentWidth,
            );
          }

          void openAnimalForm() {
            showDialog(
              context: context,
              builder: (context) => const AnimalFormDialog(),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
            ),
          );
        },
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  final double width;
  final double horizontalPadding;
  final double verticalPadding;
  final double maxContentWidth;

  const _DashboardLoading({
    required this.width,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    final widthTier = ResponsiveUtils.widthTierForWidth(width);
    final loadingExtraVerticalPadding =
        widthTier == ResponsiveWidthTier.small ||
                widthTier == ResponsiveWidthTier.medium
            ? AppSpacing.sm
            : AppSpacing.md;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding + loadingExtraVerticalPadding,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: const Padding(
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
        ),
      ),
    );
  }
}
