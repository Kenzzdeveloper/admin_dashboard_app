import 'package:flutter/material.dart';

class AnalyticsBody extends StatefulWidget {
  const AnalyticsBody({super.key});

  @override
  State<AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<AnalyticsBody> {
  int _selectedPeriod = 0; // 0=Mingguan, 1=Bulanan, 2=Tahunan

  // Sample attendance trend data (percentage per week/month)
  final List<_BarData> _weeklyData = [
    _BarData('Sen', 0.75),
    _BarData('Sel', 0.90),
    _BarData('Rab', 0.65),
    _BarData('Kam', 0.87),
    _BarData('Jum', 0.95),
    _BarData('Sab', 0.70),
    _BarData('Min', 0.45),
  ];

  final List<_BarData> _monthlyData = [
    _BarData('Jan', 0.72),
    _BarData('Feb', 0.80),
    _BarData('Mar', 0.87),
    _BarData('Apr', 0.68),
    _BarData('Mei', 0.90),
    _BarData('Jun', 0.78),
  ];

  final List<_BarData> _yearlyData = [
    _BarData('2022', 0.65),
    _BarData('2023', 0.72),
    _BarData('2024', 0.80),
    _BarData('2025', 0.85),
    _BarData('2026', 0.87),
  ];

  List<_BarData> get _currentData {
    switch (_selectedPeriod) {
      case 1:
        return _monthlyData;
      case 2:
        return _yearlyData;
      default:
        return _weeklyData;
    }
  }

  // Top event data
  final List<_EventStat> _topEvents = [
    _EventStat('Python Workshop', 45, 50, const Color(0xFF2563EB)),
    _EventStat('ML Workshop', 42, 50, const Color(0xFF7C3AED)),
    _EventStat('Algorithms Session', 28, 40, const Color(0xFF10B981)),
    _EventStat('Web Dev Bootcamp', 35, 50, const Color(0xFFF97316)),
  ];

  // Member growth data
  final List<_GrowthData> _growthData = [
    _GrowthData('Jan', 180),
    _GrowthData('Feb', 200),
    _GrowthData('Mar', 215),
    _GrowthData('Apr', 225),
    _GrowthData('Mei', 238),
    _GrowthData('Jun', 248),
  ];

  @override
  Widget build(BuildContext context) {
    final periods = ['Mingguan', 'Bulanan', 'Tahunan'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Analytics',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          const SizedBox(height: 4),
          const Text('Statistik dan performa study club',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 16),

          // Summary stat row
          Row(
            children: [
              _MiniStat(
                  label: 'Total Member',
                  value: '248',
                  trend: '+12%',
                  color: const Color(0xFF2563EB)),
              const SizedBox(width: 10),
              _MiniStat(
                  label: 'Rata Kehadiran',
                  value: '87%',
                  trend: '+5%',
                  color: const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniStat(
                  label: 'Total Event',
                  value: '12',
                  trend: '+3',
                  color: const Color(0xFF7C3AED)),
              const SizedBox(width: 10),
              _MiniStat(
                  label: 'Achievements',
                  value: '156',
                  trend: '+24',
                  color: const Color(0xFFF97316)),
            ],
          ),
          const SizedBox(height: 20),

          // Attendance trend chart
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tren Kehadiran',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827))),
                    // Period selector
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: periods.asMap().entries.map((e) {
                          final isSel = _selectedPeriod == e.key;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedPeriod = e.key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: isSel
                                    ? [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.06),
                                          blurRadius: 4,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSel
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSel
                                      ? const Color(0xFF111827)
                                      : const Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Bar chart
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _currentData.map((d) {
                      return Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${(d.value * 100).round()}%',
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                height: 130 * d.value,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      const Color(0xFF2563EB),
                                      const Color(0xFF2563EB)
                                          .withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(d.label,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF9CA3AF))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Member growth line chart (simplified)
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
                const Text('Pertumbuhan Member',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                const SizedBox(height: 4),
                const Text('6 bulan terakhir',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF9CA3AF))),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: CustomPaint(
                    painter: _LineChartPainter(_growthData),
                    size: Size.infinite,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _growthData
                      .map((d) => Text(d.label,
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF9CA3AF))))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Top events table
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
                const Text('Event Terpopuler',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827))),
                const SizedBox(height: 16),
                ..._topEvents.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final pct = e.attendees / e.capacity;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: e.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text('${i + 1}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: e.color)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(e.name,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF374151))),
                            ),
                            Text(
                              '${e.attendees}/${e.capacity}',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: e.color),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(e.color),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Helper data classes ─────────────────────────────────────────
class _BarData {
  final String label;
  final double value;
  const _BarData(this.label, this.value);
}

class _GrowthData {
  final String label;
  final int members;
  const _GrowthData(this.label, this.members);
}

class _EventStat {
  final String name;
  final int attendees;
  final int capacity;
  final Color color;
  const _EventStat(this.name, this.attendees, this.capacity, this.color);
}

// ─── Mini Stat Card ──────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: color)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.trending_up,
                    size: 13, color: const Color(0xFF10B981)),
                const SizedBox(width: 3),
                Text(trend,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981))),
                const Text(' vs bulan lalu',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Line Chart Painter ──────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<_GrowthData> data;
  _LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minVal = data.map((d) => d.members).reduce((a, b) => a < b ? a : b);
    final maxVal = data.map((d) => d.members).reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal).toDouble();

    final points = data.asMap().entries.map((entry) {
      final x = entry.key * (size.width / (data.length - 1));
      final y = size.height -
          ((entry.value.members - minVal) / range) * size.height;
      return Offset(x, y);
    }).toList();

    // Fill gradient
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2563EB).withOpacity(0.15),
          const Color(0xFF2563EB).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots
    final dotPaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;
    final dotOutline = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final p in points) {
      canvas.drawCircle(p, 5, dotOutline);
      canvas.drawCircle(p, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.data != data;
}
