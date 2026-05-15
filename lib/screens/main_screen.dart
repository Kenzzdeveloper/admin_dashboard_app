import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/app_drawer.dart';
import 'dashboard_body.dart';
import 'events_body.dart';
import 'members_body.dart';
import 'attendance_body.dart';
import 'analytics_body.dart';
import 'posts_body.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<int> _history = [0];

  void navigateTo(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _history.add(index);
      _selectedIndex = index;
    });
  }

  bool _onWillPop() {
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        _selectedIndex = _history.last;
      });
      return false;
    }
    return true;
  }

  Widget get _currentBody {
    switch (_selectedIndex) {
      case 0:
        return DashboardBody(onNavigate: navigateTo);
      case 1:
        return const MembersBody();
      case 2:
        return EventsBody(onBack: () => _onWillPop());
      case 3:
        return const AttendanceBody();
      case 4:
        return const AnalyticsBody();
      case 5:
        return const MaterialsBody();
      default:
        return DashboardBody(onNavigate: navigateTo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _onWillPop(),
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF3F8),
        drawer: AppDrawer(
          selectedIndex: _selectedIndex,
          onItemSelected: navigateTo,
        ),
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(
                showBack: _history.length > 1 && _selectedIndex != 0,
                onBack: _onWillPop,
              ),
              Expanded(child: _currentBody),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool showBack;
  final VoidCallback onBack;

  const _TopBar({required this.showBack, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: const Icon(Icons.menu,
                      color: Color(0xFF374151), size: 26),
                ),
              ),
              if (showBack) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new,
                            size: 13, color: Color(0xFF374151)),
                        SizedBox(width: 4),
                        Text('Back',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151))),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          Text(
            DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
            style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}