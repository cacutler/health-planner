import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common.dart';
import '../../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _heightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _sex;
  String? _activityLevel;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _heightCtrl.text = user.heightIn?.toString() ?? '';
      _ageCtrl.text = user.age?.toString() ?? '';
      _sex = user.sex;
      _activityLevel = user.activityLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textMuted, size: 20),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar / email block
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(color: AppTheme.divider),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  color: AppTheme.accent.withOpacity(0.15),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppTheme.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Member',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const SectionHeader(title: 'Physical Stats'),
          const SizedBox(height: 12),

          AppTextField(
            label: 'Height (inches)',
            controller: _heightCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          AppTextField(
            label: 'Age',
            controller: _ageCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),

          // Sex selector
          _DropdownField<String>(
            label: 'Sex',
            value: _sex,
            items: const ['male', 'female'],
            onChanged: (v) => setState(() => _sex = v),
          ),
          const SizedBox(height: 10),

          // Activity level
          _DropdownField<String>(
            label: 'Activity Level',
            value: _activityLevel,
            items: const ['sedentary', 'light', 'moderate', 'active'],
            onChanged: (v) => setState(() => _activityLevel = v),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving ? const AppLoader() : const Text('UPDATE PROFILE'),
            ),
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // Danger zone
          SizedBox(
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onPressed: () => context.read<AuthProvider>().logout(),
              child: const Text('SIGN OUT'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiService().updateMe({
        if (_heightCtrl.text.isNotEmpty)
          'height_in': int.parse(_heightCtrl.text),
        if (_ageCtrl.text.isNotEmpty) 'age': int.parse(_ageCtrl.text),
        if (_sex != null) 'sex': _sex,
        if (_activityLevel != null) 'activity_level': _activityLevel,
      });
      await context.read<AuthProvider>().refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppTheme.surfaceElevated,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      items: [
        DropdownMenuItem<T>(
          value: null,
          child: Text('Select...', style: TextStyle(color: AppTheme.textMuted)),
        ),
        ...items.map(
          (i) => DropdownMenuItem<T>(
            value: i,
            child: Text(i.toString().toUpperCase()),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
