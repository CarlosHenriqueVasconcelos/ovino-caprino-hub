import 'package:flutter/material.dart';

import '../../../widgets/breeding/repro_alerts_card.dart';
import '../../../widgets/vaccination/vaccination_alerts.dart';
import '../../../widgets/weight/weight_alerts_card.dart';

class DashboardAlertsSection extends StatelessWidget {
  final void Function(int) onGoToTab;

  const DashboardAlertsSection({super.key, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VaccinationAlerts(onGoToVaccinations: () => onGoToTab(5)),
        const SizedBox(height: 16),
        const ReproAlertsCard(daysAhead: 30),
        const SizedBox(height: 16),
        const WeightAlertsCard(),
      ],
    );
  }
}
