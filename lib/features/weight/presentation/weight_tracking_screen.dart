import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/animal_service.dart';
import '../../../services/weight_alert_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import 'widgets/adult_weight_tracking.dart';
import 'widgets/lamb_weight_tracking.dart';

// ── Color constants ───────────────────────────────────────────────────────────

const _kBeige = Color(0xFFF6F5F1);
const _kSurface = Color(0xFFFBFBF8);
const _kBorder = Color(0xFFE6E4DC);
const _kText = Color(0xFF22313A);
const _kText2 = Color(0xFF5A6E78);
const _kText3 = Color(0xFF9AABB4);
const _kPurple = Color(0xFF7B5EA7);
const _kPurple50 = Color(0xFFF0EBFA);

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  int _activeTab = 0; // 0 = Adultos  1 = Borregos

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBeige,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          children: [
            _buildKpiStrip(),
            _buildAlertBanner(),
            _buildSubTabRow(),
            _activeTab == 0
                ? const AdultWeightTracking(embedInParentScroll: true)
                : const LambWeightTracking(embedInParentScroll: true),
          ],
        ),
      ),
    );
  }

  // ── KPI strip ─────────────────────────────────────────────────────────────

  Widget _buildKpiStrip() {
    final stats = context.watch<AnimalService>().stats;
    final lambCount = (stats?.maleLambs ?? 0) + (stats?.femaleLambs ?? 0);
    final adultCount = (stats?.totalAnimals ?? 0) - lambCount;

    return Consumer<WeightAlertService>(
      builder: (context, wSvc, _) {
        final pending = wSvc.pendingAlerts.length;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: _KpiTile(
                  iconBg: AppColors.primary.withValues(alpha: 0.10),
                  iconColor: AppColors.primary,
                  icon: Icons.person_outline,
                  value: '$adultCount',
                  label: 'Adultos',
                  detail: '24 meses',
                  detailColor: _kText3,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _KpiTile(
                  iconBg: _kPurple50,
                  iconColor: _kPurple,
                  icon: Icons.group_outlined,
                  value: '$lambCount',
                  label: 'Borregos',
                  detail: '0–120 dias',
                  detailColor: _kText3,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: _KpiTile(
                  iconBg: AppColors.primary.withValues(alpha: 0.10),
                  iconColor: AppColors.primary,
                  icon: Icons.check_circle_outline,
                  value: pending > 0 ? '$pending' : 'Em dia',
                  label: 'Alertas',
                  detail:
                      pending > 0 ? '$pending atraso${pending > 1 ? 's' : ''}' : '0 atrasos',
                  detailColor:
                      pending > 0 ? const Color(0xFFC94A4A) : AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Alert banner ──────────────────────────────────────────────────────────

  Widget _buildAlertBanner() {
    return Consumer<WeightAlertService>(
      builder: (context, wSvc, _) {
        final pending = wSvc.pendingAlerts.length;
        final hasAlerts = pending > 0;
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            0,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder.withValues(alpha: 0.8)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alertas de Pesagem',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _kText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasAlerts
                            ? '$pending pesagem${pending > 1 ? 's' : ''} em atraso'
                            : 'Todas as pesagens estão em dia',
                        style: const TextStyle(
                          fontSize: 8,
                          color: _kText3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasAlerts
                        ? const Color(0xFFFAEAEA)
                        : AppColors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    hasAlerts ? '$pending Pendente${pending > 1 ? 's' : ''}' : 'Em dia',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: hasAlerts
                          ? const Color(0xFFC94A4A)
                          : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Sub-tab row ───────────────────────────────────────────────────────────

  Widget _buildSubTabRow() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xs),
      decoration: const BoxDecoration(
        color: _kSurface,
        border: Border(
          top: BorderSide(color: _kBorder, width: 0.8),
          bottom: BorderSide(color: _kBorder, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          _SubTab(
            icon: Icons.person_outline,
            label: 'Adultos',
            isActive: _activeTab == 0,
            activeIconBg: AppColors.primary.withValues(alpha: 0.10),
            activeIconColor: AppColors.primary,
            activeBorderColor: AppColors.primary,
            onTap: () => setState(() => _activeTab = 0),
          ),
          _SubTab(
            icon: Icons.group_outlined,
            label: 'Borregos',
            isActive: _activeTab == 1,
            activeIconBg: _kPurple50,
            activeIconColor: _kPurple,
            activeBorderColor: _kPurple,
            onTap: () => setState(() => _activeTab = 1),
          ),
        ],
      ),
    );
  }
}

// ── KPI tile ──────────────────────────────────────────────────────────────────

class _KpiTile extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String value;
  final String label;
  final String? detail;
  final Color detailColor;

  const _KpiTile({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.value,
    required this.label,
    this.detail,
    required this.detailColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 11, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              color: _kText2,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 1),
            Text(
              detail!,
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.w500,
                color: detailColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Sub-tab ───────────────────────────────────────────────────────────────────

class _SubTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeIconBg;
  final Color activeIconColor;
  final Color activeBorderColor;
  final VoidCallback onTap;

  const _SubTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeIconBg,
    required this.activeIconColor,
    required this.activeBorderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 8, 6, 0),
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isActive
                            ? activeIconBg
                            : const Color(0xFFF2F1ED),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        icon,
                        size: 12,
                        color: isActive ? activeIconColor : _kText3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isActive ? activeIconColor : _kText3,
                      ),
                    ),
                    const SizedBox(height: 7),
                  ],
                ),
              ),
              Container(
                height: 2,
                color: isActive ? activeBorderColor : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
