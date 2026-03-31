import 'package:flutter/material.dart';

import '../../../shared/widgets/common/app_card.dart';
import '../../../shared/widgets/common/metric_card.dart';
import '../../../shared/widgets/common/section_header.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'widgets/adult_weight_tracking.dart';
import 'widgets/lamb_weight_tracking.dart';
import 'widgets/weight_alerts_card.dart';

class WeightTrackingScreen extends StatelessWidget {
  const WeightTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        color: AppColors.background,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: AppCard(
                variant: AppCardVariant.soft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Controle de Peso',
                      subtitle:
                          'Acompanhe evolução, marcos e alertas de pesagem do rebanho',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final columns = width >= 980 ? 3 : (width >= 600 ? 2 : 1);

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: columns,
                          crossAxisSpacing: AppSpacing.xs,
                          mainAxisSpacing: AppSpacing.xs,
                          childAspectRatio: columns == 1 ? 2.8 : 2.3,
                          children: const [
                            MetricCard(
                              title: 'Adultos',
                              value: '24 meses',
                              subtitle: 'Controle mensal contínuo',
                              icon: Icons.scale,
                            ),
                            MetricCard(
                              title: 'Borregos',
                              value: '0-120 dias',
                              subtitle: 'Marcos aos 30, 60, 90 e 120 dias',
                              icon: Icons.baby_changing_station,
                              accentColor: AppColors.primarySupport,
                            ),
                            MetricCard(
                              title: 'Alertas',
                              value: 'Automáticos',
                              subtitle: 'Pendências de pesagem em destaque',
                              icon: Icons.notifications_active_outlined,
                              accentColor: AppColors.warning,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: WeightAlertsCard(),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: AppCard(
                variant: AppCardVariant.elevated,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.scale), text: 'Adultos'),
                    Tab(icon: Icon(Icons.baby_changing_station), text: 'Borregos'),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  AdultWeightTracking(),
                  LambWeightTracking(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
