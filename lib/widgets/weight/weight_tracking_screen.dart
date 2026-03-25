import 'package:flutter/material.dart';

import 'adult_weight_tracking.dart';
import 'lamb_weight_tracking.dart';

class WeightTrackingScreen extends StatelessWidget {
  const WeightTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: theme.scaffoldBackgroundColor,
            child: TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: theme.colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.scale), text: 'Adultos'),
                Tab(icon: Icon(Icons.baby_changing_station), text: 'Borregos'),
              ],
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
    );
  }
}
