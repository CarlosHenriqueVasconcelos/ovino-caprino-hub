import 'package:flutter/material.dart';

import '../../breeding/presentation/widgets/repro_alerts_card.dart';
import '../../medication/presentation/widgets/vaccination_alerts.dart';
import '../../weight/presentation/widgets/weight_alerts_card.dart';

class DashboardAlertsSection extends StatelessWidget {
  final void Function(int) onGoToTab;

  const DashboardAlertsSection({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VaccinationAlerts(onGoToVaccinations: () => onGoToTab(6)),
        const SizedBox(height: 16),
        const ReproAlertsCard(daysAhead: 30),
        const SizedBox(height: 16),
        const WeightAlertsCard(),
      ],
    );
  }
}
