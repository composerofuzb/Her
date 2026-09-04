import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../domain/models/daily_log.dart';

class SubjectRowWidget extends StatelessWidget {
  final String subjectName;
  final SubjectData data;
  final ValueChanged<SubjectData> onChanged;

  const SubjectRowWidget({
    super.key,
    required this.subjectName,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.nebulaDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subjectName, style: AppTypography.titleMedium),
              Row(
                children: [
                  SizedBox(
                    width: 65,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: '${data.mark.toInt()}',
                        hintStyle: const TextStyle(color: Colors.white38),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        filled: true,
                        fillColor: AppColors.nebulaCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (val) {
                        final mark = double.tryParse(val) ?? data.mark;
                        onChanged(data.copyWith(mark: mark.clamp(0, 100)));
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('/ 100', style: AppTypography.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Homework: ', style: AppTypography.bodySmall.copyWith(fontSize: 12)),
              const SizedBox(width: 8),
              _hwChoice('Done', 'yes', Colors.green),
              const SizedBox(width: 6),
              _hwChoice('Partial', 'partial', Colors.orange),
              const SizedBox(width: 6),
              _hwChoice('None', 'no', Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _hwChoice(String label, String value, Color color) {
    final isSelected = data.homework == value;
    return GestureDetector(
      onTap: () => onChanged(data.copyWith(homework: value)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.white60,
          ),
        ),
      ),
    );
  }
}
