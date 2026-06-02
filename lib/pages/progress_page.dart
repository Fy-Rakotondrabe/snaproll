import 'package:flutter/material.dart';
import '../l10n/app_l10n.dart';
import '../services/settings_service.dart';
import '../theme/app_colors.dart';
import '../widgets/snap_app_bar.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int _streak = 0;
  int _record = 0;
  List<bool> _week = List.filled(7, false);

  @override
  void initState() {
    super.initState();
    SettingsService.spinNotifier.addListener(_reload);
    _reload();
  }

  @override
  void dispose() {
    SettingsService.spinNotifier.removeListener(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    final streak = await SettingsService.getCurrentStreak();
    final record = await SettingsService.getRecordStreak();
    final week = await SettingsService.getWeekActivity();
    if (!mounted) return;
    setState(() {
      _streak = streak;
      _record = record;
      _week = week;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: SnapAppBar(title: l.progressTitle, subtitle: l.progressSubtitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _DailyStreakCard(streak: _streak, l: l, colors: colors),
            const SizedBox(height: 16),
            _RecordCard(record: _record, l: l, colors: colors),
            const SizedBox(height: 24),
            Text(
              l.progressThisWeek,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: colors.textSecondary,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 12),
            _WeekGrid(activity: _week, colors: colors),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DailyStreakCard extends StatelessWidget {
  const _DailyStreakCard({required this.streak, required this.l, required this.colors});
  final int streak;
  final AppL10n l;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF6B35).withValues(alpha: 0.25),
            const Color(0xFFFF6B35).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF6B35).withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.local_fire_department_rounded,
                  color: Color(0xFFFF6B35), size: 34),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.progressStreakLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.textSecondary,
                      )),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$streak',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: const Color(0xFFFF6B35),
                          )),
                  const SizedBox(width: 6),
                  Text(l.progressStreakUnit,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                          )),
                ],
              ),
              Text(
                streak > 0 ? l.progressStreakMotivation : '',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFFF6B35).withValues(alpha: 0.8),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.l, required this.colors});
  final int record;
  final AppL10n l;
  final AppColorsExtension colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.surfaceElevated),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.premium.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: AppColors.premium, size: 26),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.progressRecord,
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$record',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.premium,
                          )),
                  const SizedBox(width: 4),
                  Text(l.progressStreakUnit,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({required this.activity, required this.colors});
  final List<bool> activity;
  final AppColorsExtension colors;

  static const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // 0=Mon, 6=Sun
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.surfaceElevated),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final done = i < activity.length && activity[i];
          final isToday = i == today;
          return Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : colors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: isToday
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 18)
                      : Icon(Icons.close_rounded,
                          color: colors.textSecondary, size: 16),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _days[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  color: done ? colors.textPrimary : colors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
