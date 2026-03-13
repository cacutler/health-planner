import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/data_providers.dart';
import '../../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final workouts = context.watch<WorkoutProvider>().workouts;
    final nutrition = context.watch<NutritionProvider>();
    final weight = context.watch<WeightProvider>();

    final recentWorkout = workouts.isNotEmpty ? workouts.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()).toUpperCase(),
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'Hello, ${user?.email.split('@').first ?? 'Athlete'}',
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppTheme.accent,
        backgroundColor: AppTheme.surface,
        onRefresh: () async {
          await Future.wait([
            context.read<WorkoutProvider>().fetchWorkouts(),
            context.read<NutritionProvider>().fetchLogs(),
            context.read<WeightProvider>().fetchLogs(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Stats row ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'CALORIES TODAY',
                    value: '${nutrition.todayCalories}',
                    unit: 'kcal',
                    valueColor: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                    label: 'CURRENT WEIGHT',
                    value: weight.latest != null
                        ? weight.latest!.weightLbs.toStringAsFixed(1)
                        : '--',
                    unit: 'lbs',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'WORKOUTS TOTAL',
                    value: '${workouts.length}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                    label: 'LAST WORKOUT',
                    value: recentWorkout != null
                        ? DateFormat('MMM d').format(recentWorkout.performedAt)
                        : '--',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Recent workout ─────────────────────────────────────────────
            const SectionHeader(title: 'Last Workout'),
            const SizedBox(height: 12),
            if (recentWorkout != null)
              _WorkoutCard(workout: recentWorkout)
            else
              _EmptyCard('No workouts yet. Log your first session!'),

            const SizedBox(height: 32),

            // ── Recent nutrition ───────────────────────────────────────────
            const SectionHeader(title: 'Recent Nutrition'),
            const SizedBox(height: 12),
            if (nutrition.logs.isNotEmpty)
              ...nutrition.logs.take(3).map((l) => _NutritionRow(log: l))
            else
              _EmptyCard('No nutrition logs yet.'),
          ],
        ),
      ),
    );
  }

  Widget _EmptyCard(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.divider),
        color: AppTheme.surface,
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final dynamic workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final isStrength = workout.type == 'strength';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 56,
            color: isStrength ? AppTheme.strength : AppTheme.cardio,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TypeChip(
                      label: workout.type,
                      color: isStrength ? AppTheme.strength : AppTheme.cardio,
                    ),
                    const SizedBox(width: 8),
                    TypeChip(label: workout.intensity),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${workout.durationMinutes} min'
                  '${workout.caloriesBurned != null ? ' · ${workout.caloriesBurned} kcal' : ''}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  DateFormat('EEE, MMM d · h:mm a').format(workout.performedAt),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (workout.exercises.isNotEmpty)
            Text(
              '${workout.exercises.length} exercises',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final dynamic log;
  const _NutritionRow({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              DateFormat('MMM d, h:mm a').format(log.loggedAt),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            '${log.calories} kcal',
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (log.proteinG != null) ...[
            const SizedBox(width: 12),
            Text(
              '${log.proteinG!.toStringAsFixed(0)}g protein',
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}
