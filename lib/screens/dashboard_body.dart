import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/activity_item_widget.dart';
import '../widgets/upcoming_event_card.dart';
import '../models/app_models.dart';

class DashboardBody extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardBody({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Stat cards
          StatCard(
            title: 'Total Members',
            value: '248',
            change: '+12%',
            icon: Icons.people_outline,
            iconColor: const Color(0xFF2563EB),
            iconBgColor: const Color(0xFFEFF6FF),
          ),
          const SizedBox(height: 12),
          StatCard(
            title: 'Active Events',
            value: '12',
            change: '+3',
            icon: Icons.calendar_today_outlined,
            iconColor: const Color(0xFF10B981),
            iconBgColor: const Color(0xFFECFDF5),
          ),
          const SizedBox(height: 12),
          StatCard(
            title: 'Attendance Rate',
            value: '87%',
            change: '+5%',
            icon: Icons.trending_up,
            iconColor: const Color(0xFF7C3AED),
            iconBgColor: const Color(0xFFF5F3FF),
          ),
          const SizedBox(height: 12),
          StatCard(
            title: 'Achievements',
            value: '156',
            change: '+24',
            icon: Icons.workspace_premium_outlined,
            iconColor: const Color(0xFFF97316),
            iconBgColor: const Color(0xFFFFF7ED),
          ),
          const SizedBox(height: 20),

          // Recent Activity
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                ...sampleActivities
                    .map((a) => ActivityItemWidget(activity: a)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Upcoming Events header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              TextButton(
                onPressed: () => onNavigate(2), // go to Events
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...sampleEvents.map((e) => UpcomingEventCard(event: e)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
