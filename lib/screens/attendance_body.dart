import 'package:flutter/material.dart';
import '../models/app_models.dart';

class AttendanceBody extends StatefulWidget {
  const AttendanceBody({super.key});

  @override
  State<AttendanceBody> createState() => _AttendanceBodyState();
}

class _AttendanceBodyState extends State<AttendanceBody> {
  String _selectedStatus = 'All'; // 'All' | 'present' | 'absent' | 'late'
  String _selectedEvent = 'All';

  List<String> get _eventOptions {
    final events = sampleAttendances.map((a) => a.eventTitle).toSet().toList();
    return ['All', ...events];
  }

  List<AttendanceModel> get _filtered {
    return sampleAttendances.where((a) {
      final matchStatus =
          _selectedStatus == 'All' || a.status == _selectedStatus;
      final matchEvent =
          _selectedEvent == 'All' || a.eventTitle == _selectedEvent;
      return matchStatus && matchEvent;
    }).toList();
  }

  int get _presentCount =>
      sampleAttendances.where((a) => a.status == 'present').length;
  int get _absentCount =>
      sampleAttendances.where((a) => a.status == 'absent').length;
  int get _lateCount =>
      sampleAttendances.where((a) => a.status == 'late').length;

  @override
  Widget build(BuildContext context) {
    final statuses = ['All', 'present', 'absent', 'late'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Attendance',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          const SizedBox(height: 4),
          const Text('Rekap kehadiran semua member',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),

          // Summary cards
          Row(
            children: [
              Expanded(
                  child: _SummaryCard(
                label: 'Hadir',
                count: _presentCount,
                color: const Color(0xFF10B981),
                bgColor: const Color(0xFFECFDF5),
                icon: Icons.check_circle_outline,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _SummaryCard(
                label: 'Terlambat',
                count: _lateCount,
                color: const Color(0xFFF59E0B),
                bgColor: const Color(0xFFFFFBEB),
                icon: Icons.access_time_outlined,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: _SummaryCard(
                label: 'Tidak Hadir',
                count: _absentCount,
                color: const Color(0xFFEF4444),
                bgColor: const Color(0xFFFEF2F2),
                icon: Icons.cancel_outlined,
              )),
            ],
          ),
          const SizedBox(height: 16),

          // Event filter dropdown
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedEvent,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down,
                    color: Color(0xFF9CA3AF)),
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w500),
                items: _eventOptions
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e == 'All' ? 'Semua Event' : e,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedEvent = val ?? 'All'),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: statuses.map((s) {
                final isSelected = _selectedStatus == s;
                final label = s == 'All'
                    ? 'Semua'
                    : s == 'present'
                        ? 'Hadir'
                        : s == 'absent'
                            ? 'Tidak Hadir'
                            : 'Terlambat';
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedStatus = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          Text('${_filtered.length} data kehadiran',
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 10),

          // Attendance list
          if (_filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(Icons.event_busy_outlined,
                        size: 56, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('Tidak ada data',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 15)),
                  ],
                ),
              ),
            )
          else
            ..._filtered.map((a) => _AttendanceCard(attendance: a)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.count,
    required this.color,
    required this.bgColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text('$count',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF9CA3AF)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceModel attendance;

  const _AttendanceCard({required this.attendance});

  Color get _statusColor {
    switch (attendance.status) {
      case 'present':
        return const Color(0xFF10B981);
      case 'absent':
        return const Color(0xFFEF4444);
      case 'late':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  Color get _statusBg {
    switch (attendance.status) {
      case 'present':
        return const Color(0xFFECFDF5);
      case 'absent':
        return const Color(0xFFFEF2F2);
      case 'late':
        return const Color(0xFFFFFBEB);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  String get _statusLabel {
    switch (attendance.status) {
      case 'present':
        return 'Hadir';
      case 'absent':
        return 'Tidak Hadir';
      case 'late':
        return 'Terlambat';
      default:
        return attendance.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(attendance.avatarInitials,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2563EB))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attendance.memberName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(attendance.eventTitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(attendance.date,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(_statusLabel,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _statusColor)),
          ),
        ],
      ),
    );
  }
}
