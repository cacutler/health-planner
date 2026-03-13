import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/nutrition_log.dart';
import '../../providers/data_providers.dart';
import '../../widgets/common.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().fetchLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NUTRITION'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.accent),
            onPressed: () => _showLogSheet(context),
          ),
        ],
      ),
      body: Consumer<NutritionProvider>(
        builder: (context, provider, _) {
          if (provider.loading) return const AppLoader();
          return RefreshIndicator(
            color: AppTheme.accent,
            backgroundColor: AppTheme.surface,
            onRefresh: provider.fetchLogs,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Today summary
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                    color: AppTheme.accent.withOpacity(0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TODAY',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${provider.todayCalories} kcal',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (provider.logs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text(
                        'No nutrition logs yet.',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ),
                  )
                else
                  ...provider.logs.map((l) => _NutritionCard(log: l)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      builder: (_) => const _LogNutritionSheet(),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final NutritionModel log;
  const _NutritionCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(log.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.error.withOpacity(0.15),
        child: const Icon(Icons.delete_outline, color: AppTheme.error),
      ),
      onDismissed: (_) => context.read<NutritionProvider>().deleteLog(log.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEE, MMM d · h:mm a').format(log.loggedAt),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (log.proteinG != null)
                        _MacroChip('P', log.proteinG!, const Color(0xFF60A5FA)),
                      if (log.carbsG != null)
                        _MacroChip('C', log.carbsG!, const Color(0xFFFBBF24)),
                      if (log.fatG != null)
                        _MacroChip('F', log.fatG!, const Color(0xFFF87171)),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              '${log.calories}',
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'kcal',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _MacroChip(String label, double value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label ${value.toStringAsFixed(0)}g',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LogNutritionSheet extends StatefulWidget {
  const _LogNutritionSheet();

  @override
  State<_LogNutritionSheet> createState() => _LogNutritionSheetState();
}

class _LogNutritionSheetState extends State<_LogNutritionSheet> {
  final _caloriesCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
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
              'LOG NUTRITION',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Calories *',
              controller: _caloriesCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'Protein (g)',
                    controller: _proteinCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    label: 'Carbs (g)',
                    controller: _carbsCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    label: 'Fat (g)',
                    controller: _fatCtrl,
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
                child: _saving ? const AppLoader() : const Text('SAVE'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_caloriesCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    await context.read<NutritionProvider>().logNutrition(
      calories: int.parse(_caloriesCtrl.text),
      loggedAt: DateTime.now(),
      proteinG: _proteinCtrl.text.isNotEmpty
          ? double.parse(_proteinCtrl.text)
          : null,
      carbsG: _carbsCtrl.text.isNotEmpty ? double.parse(_carbsCtrl.text) : null,
      fatG: _fatCtrl.text.isNotEmpty ? double.parse(_fatCtrl.text) : null,
    );
    if (mounted) Navigator.pop(context);
  }
}
