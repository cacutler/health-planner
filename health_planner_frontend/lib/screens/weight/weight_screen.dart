import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../models/weight_log.dart';
import '../../providers/data_providers.dart';
import '../../widgets/common.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeightProvider>().fetchLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WEIGHT'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.accent),
            onPressed: () => _showLogSheet(context),
          ),
        ],
      ),
      body: Consumer<WeightProvider>(
        builder: (context, provider, _) {
          if (provider.loading) return const AppLoader();
          return RefreshIndicator(
            color: AppTheme.accent,
            backgroundColor: AppTheme.surface,
            onRefresh: provider.fetchLogs,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (provider.latest != null)
                  StatTile(
                    label: 'CURRENT WEIGHT',
                    value: provider.latest!.weightLbs.toStringAsFixed(1),
                    unit: 'lbs',
                    valueColor: AppTheme.accent,
                  ),

                if (provider.logs.length > 1) ...[
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Progress'),
                  const SizedBox(height: 12),
                  _WeightChart(logs: provider.logs),
                ],

                const SizedBox(height: 24),
                const SectionHeader(title: 'History'),
                const SizedBox(height: 12),

                if (provider.logs.isEmpty)
                  const Center(
                    child: Text(
                      'No weight logs yet.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  )
                else
                  ...provider.logs.map((l) => _WeightRow(log: l)),
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
      builder: (_) => const _LogWeightSheet(),
    );
  }
}

class _WeightChart extends StatelessWidget {
  final List<WeightLogModel> logs;
  const _WeightChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    // Show last 10 entries chronologically
    final sorted = logs.reversed.toList().take(10).toList();
    final spots = sorted.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weightLbs);
    }).toList();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 2;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 2;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.divider),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: AppTheme.divider, strokeWidth: 1),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  v.toStringAsFixed(0),
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= sorted.length) return const SizedBox();
                  return Text(
                    DateFormat('M/d').format(sorted[i].loggedAt),
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 9,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.accent,
              barWidth: 2,
              dotData: FlDotData(
                getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                  radius: 3,
                  color: AppTheme.accent,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.accent.withOpacity(0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightRow extends StatelessWidget {
  final WeightLogModel log;
  const _WeightRow({required this.log});

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
      onDismissed: (_) => context.read<WeightProvider>().deleteLog(log.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('EEE, MMM d y').format(log.loggedAt),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            Text(
              '${log.weightLbs.toStringAsFixed(1)} lbs',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogWeightSheet extends StatefulWidget {
  const _LogWeightSheet();

  @override
  State<_LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends State<_LogWeightSheet> {
  final _weightCtrl = TextEditingController();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'LOG WEIGHT',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Weight (lbs)',
            controller: _weightCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
    );
  }

  Future<void> _save() async {
    if (_weightCtrl.text.isEmpty) return;
    setState(() => _saving = true);
    await context.read<WeightProvider>().logWeight(
      double.parse(_weightCtrl.text),
      DateTime.now(),
    );
    if (mounted) Navigator.pop(context);
  }
}
