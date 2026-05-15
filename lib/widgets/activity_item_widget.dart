import 'package:flutter/material.dart';
import '../models/app_models.dart';

class ActivityItemWidget extends StatelessWidget {
  final ActivityModel activity;

  const ActivityItemWidget({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.timeAgo,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _bgColor {
    switch (activity.type) {
      case 'member':
        return const Color(0xFFEFF6FF);
      case 'event':
        return const Color(0xFFECFDF5);
      case 'milestone':
        return const Color(0xFFF5F3FF);
      case 'alert':
        return const Color(0xFFFFF7ED);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color get _iconColor {
    switch (activity.type) {
      case 'member':
        return const Color(0xFF2563EB);
      case 'event':
        return const Color(0xFF10B981);
      case 'milestone':
        return const Color(0xFF7C3AED);
      case 'alert':
        return const Color(0xFFF97316);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData get _icon {
    switch (activity.type) {
      case 'member':
        return Icons.person_add_outlined;
      case 'event':
        return Icons.calendar_today_outlined;
      case 'milestone':
        return Icons.workspace_premium_outlined;
      case 'alert':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }
}
