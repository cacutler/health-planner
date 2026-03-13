import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/common.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkoutProvider>().fetchWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WORKOUTS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.accent),
            onPressed: () => _showCreateWorkout(context),
          ),
        ],
      ),
      body: Consumer<WorkoutProvider>(
        builder: (context, provider, _) {
          if (provider.loading) return const AppLoader();
          if (provider.workouts.isEmpty) {
            return const Center(
              child: Text(
                'No workouts yet.\nTap + to log your first.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted),
              ),
            );
          }
          return RefreshIndicator(
            color: AppTheme.accent,
            backgroundColor: AppTheme.surface,
            onRefresh: provider.fetchWorkouts,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.workouts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) =>
                  _WorkoutTile(workout: provider.workouts[i]),
            ),
          );
        },
      ),
    );
  }

  void _showCreateWorkout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      builder: (_) => const _CreateWorkoutSheet(),
    );
  }
}

class _WorkoutTile extends StatelessWidget {
  final WorkoutModel workout;
  const _WorkoutTile({required this.workout});

  @override
  Widget build(BuildContext context) {
    final isStrength = workout.type == 'strength';
    return Dismissible(
      key: Key(workout.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.error.withOpacity(0.15),
        child: const Icon(Icons.delete_outline, color: AppTheme.error),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.surface,
            title: const Text(
              'Delete workout?',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppTheme.error),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) =>
          context.read<WorkoutProvider>().deleteWorkout(workout.id),
      child: GestureDetector(
        onTap: () => _showDetail(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border.all(color: AppTheme.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
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
                          color: isStrength
                              ? AppTheme.strength
                              : AppTheme.cardio,
                        ),
                        const SizedBox(width: 6),
                        TypeChip(label: workout.intensity),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${workout.durationMinutes} min'
                      '${workout.caloriesBurned != null ? '  ·  ${workout.caloriesBurned} kcal' : ''}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('EEE MMM d, y').format(workout.performedAt),
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${workout.exercises.length}',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'exercises',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      builder: (_) => _WorkoutDetailSheet(workout: workout),
    );
  }
}

class _WorkoutDetailSheet extends StatelessWidget {
  final WorkoutModel workout;
  const _WorkoutDetailSheet({required this.workout});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scroll) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${workout.type.toUpperCase()} SESSION',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.accent,
                  ),
                  onPressed: () => _showAddExercise(context),
                ),
              ],
            ),
            Text(
              DateFormat('EEEE, MMMM d y').format(workout.performedAt),
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                StatTile(
                  label: 'DURATION',
                  value: '${workout.durationMinutes}',
                  unit: 'min',
                ),
                const SizedBox(width: 8),
                StatTile(
                  label: 'CALORIES',
                  value: workout.caloriesBurned?.toString() ?? '--',
                  unit: 'kcal',
                  valueColor: AppTheme.accent,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Exercises'),
            const SizedBox(height: 8),
            Expanded(
              child: workout.exercises.isEmpty
                  ? const Center(
                      child: Text(
                        'No exercises logged.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    )
                  : ListView.separated(
                      controller: scroll,
                      itemCount: workout.exercises.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final ex = workout.exercises[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            ex.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            [
                              if (ex.sets != null) '${ex.sets} sets',
                              if (ex.reps != null) '${ex.reps} reps',
                              if (ex.weightLbs != null) '${ex.weightLbs} lbs',
                              if (ex.durationSeconds != null)
                                '${ex.durationSeconds}s',
                            ].join(' · '),
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExercise(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      builder: (_) => _AddExerciseSheet(workoutId: workout.id),
    );
  }
}

// ── Create Workout Sheet ──────────────────────────────────────────────────────

class _CreateWorkoutSheet extends StatefulWidget {
  const _CreateWorkoutSheet();

  @override
  State<_CreateWorkoutSheet> createState() => _CreateWorkoutSheetState();
}

class _CreateWorkoutSheetState extends State<_CreateWorkoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _durationCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  String _type = 'strength';
  String _intensity = 'medium';
  DateTime _performedAt = DateTime.now();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'LOG WORKOUT',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),

              // Type selector
              Row(
                children: [
                  _TypeButton(
                    'strength',
                    _type,
                    (v) => setState(() => _type = v),
                  ),
                  const SizedBox(width: 8),
                  _TypeButton(
                    'cardio',
                    _type,
                    (v) => setState(() => _type = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Intensity selector
              Row(
                children: [
                  _IntensityButton(
                    'low',
                    _intensity,
                    (v) => setState(() => _intensity = v),
                  ),
                  const SizedBox(width: 8),
                  _IntensityButton(
                    'medium',
                    _intensity,
                    (v) => setState(() => _intensity = v),
                  ),
                  const SizedBox(width: 8),
                  _IntensityButton(
                    'high',
                    _intensity,
                    (v) => setState(() => _intensity = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              AppTextField(
                label: 'Duration (minutes)',
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Calories burned (optional)',
                controller: _caloriesCtrl,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // Date picker
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _performedAt,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppTheme.accent,
                          surface: AppTheme.surface,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (d != null) setState(() => _performedAt = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceElevated,
                    border: Border.all(
                      color: AppTheme.textMuted.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEE, MMM d y').format(_performedAt),
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const AppLoader()
                      : const Text('SAVE WORKOUT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await context.read<WorkoutProvider>().createWorkout(
      type: _type,
      durationMinutes: int.parse(_durationCtrl.text),
      intensity: _intensity,
      performedAt: _performedAt,
      caloriesBurned: _caloriesCtrl.text.isNotEmpty
          ? int.tryParse(_caloriesCtrl.text)
          : null,
    );
    if (mounted) {
      if (ok != null) Navigator.pop(context);
      setState(() => _saving = false);
    }
  }

  Widget _TypeButton(
    String value,
    String current,
    void Function(String) onTap,
  ) {
    final selected = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? (value == 'strength' ? AppTheme.strength : AppTheme.cardio)
                      .withOpacity(0.15)
                : AppTheme.surfaceElevated,
            border: Border.all(
              color: selected
                  ? (value == 'strength' ? AppTheme.strength : AppTheme.cardio)
                  : AppTheme.textMuted.withOpacity(0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toUpperCase(),
            style: TextStyle(
              color: selected
                  ? (value == 'strength' ? AppTheme.strength : AppTheme.cardio)
                  : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _IntensityButton(
    String value,
    String current,
    void Function(String) onTap,
  ) {
    final selected = value == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.accent.withOpacity(0.12)
                : AppTheme.surfaceElevated,
            border: Border.all(
              color: selected
                  ? AppTheme.accent
                  : AppTheme.textMuted.withOpacity(0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toUpperCase(),
            style: TextStyle(
              color: selected ? AppTheme.accent : AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Add Exercise Sheet ────────────────────────────────────────────────────────

class _AddExerciseSheet extends StatefulWidget {
  final String workoutId;
  const _AddExerciseSheet({required this.workoutId});

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _nameCtrl = TextEditingController();
  final _setsCtrl = TextEditingController();
  final _repsCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'ADD EXERCISE',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Exercise name', controller: _nameCtrl),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Sets',
                    controller: _setsCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    label: 'Reps',
                    controller: _repsCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Weight (lbs)',
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    label: 'Duration (sec)',
                    controller: _durationCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving ? const AppLoader() : const Text('ADD'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    await context.read<WorkoutProvider>().addExercise(widget.workoutId, {
      'name': _nameCtrl.text,
      if (_setsCtrl.text.isNotEmpty) 'sets': int.parse(_setsCtrl.text),
      if (_repsCtrl.text.isNotEmpty) 'reps': int.parse(_repsCtrl.text),
      if (_weightCtrl.text.isNotEmpty)
        'weight_lbs': double.parse(_weightCtrl.text),
      if (_durationCtrl.text.isNotEmpty)
        'duration_seconds': int.parse(_durationCtrl.text),
    });
    if (mounted) Navigator.pop(context);
  }
}
