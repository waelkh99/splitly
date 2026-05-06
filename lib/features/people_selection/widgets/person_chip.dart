import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/person.dart';

class PersonChip extends StatelessWidget {
  const PersonChip({
    super.key,
    required this.person,
    required this.selected,
    required this.onTap,
    this.index = 0,
  });

  final Person person;
  final bool selected;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.avatarFor(index);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : const Color(0xFFE0E0E0),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor:
                  selected ? color : color.withValues(alpha: 0.2),
              child: Text(
                person.name.isNotEmpty
                    ? person.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : color,
                ),
              ),
            ),
            const SizedBox(width: 7),
            Text(
              person.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? color : const Color(0xFF333333),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_rounded, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }
}
