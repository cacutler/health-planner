import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Stat tile — label + big value
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color? valueColor;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    unit!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Section header with optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

/// Accent tag chip
class TypeChip extends StatelessWidget {
  final String label;
  final Color? color;

  const TypeChip({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: c,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// Subtle loading indicator
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.accent,
        ),
      ),
    );
  }
}

/// Error message display
class ErrorMessage extends StatelessWidget {
  final String message;
  const ErrorMessage(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.08),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// Labeled text field
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final String? hint;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
