import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../l10n/app_l10n.dart';
import '../widgets/snap_app_bar.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: SnapAppBar(title: l.progressTitle, subtitle: l.progressSubtitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              const SizedBox(height: 8),
              // Streak card — big and prominent
              _DailyStreakCard(streak: 12),
              const SizedBox(height: 16),
              _RecordCard(record: 38),
              const SizedBox(height: 24),
              Text(
                l.progressMostDone,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: context.colors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              _TopChallengeCard(
                name: 'Règle des tiers',
                tag: 'COMPOSITION',
                tagColor: AppColors.success,
                count: 23,
              ),
              const SizedBox(height: 24),
              Text(
                l.progressThisWeek,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: context.colors.textSecondary,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 12),
              _WeekGrid(),
              const SizedBox(height: 32),
            ],
          ),
        ),
    );
  }
}

class _DailyStreakCard extends StatelessWidget {
  const _DailyStreakCard({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
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
              child: Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF6B35),
                size: 34,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.progressStreakLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: context.colors.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$streak',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: const Color(0xFFFF6B35),
                          fontFamily: 'SpaceGrotesk',
                        ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l.progressStreakUnit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.textSecondary,
                        ),
                  ),
                ],
              ),
              Text(
                l.progressStreakMotivation,
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
  const _RecordCard({required this.record});
  final int record;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.surfaceElevated),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppColors.premium, size: 26),
          const SizedBox(height: 12),
          Text(
            l.progressRecord,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$record',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.premium,
                    ),
              ),
              const SizedBox(width: 4),
              Text('j', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopChallengeCard extends StatelessWidget {
  const _TopChallengeCard({
    required this.name,
    required this.tag,
    required this.tagColor,
    required this.count,
  });

  final String name;
  final String tag;
  final Color tagColor;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tagColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.workspace_premium_rounded,
                color: tagColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: tagColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Inter',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(name, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$count',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: tagColor,
                      fontSize: 26,
                    ),
              ),
              Text(l.progressTimes, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid();

  static const _days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
  static const _done = [true, true, false, true, true, true, false];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_days.length, (i) {
          final done = _done[i];
          return Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : context.colors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: done
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.5))
                      : null,
                ),
                child: Center(
                  child: done
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 18)
                      : Icon(Icons.close_rounded,
                          color: context.colors.textSecondary, size: 16),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _days[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color:
                      done ? context.colors.textPrimary : context.colors.textSecondary,
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
