import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'assistant_screen.dart';
import 'lecturer_directory_screen.dart';
import 'bus_schedule_screen.dart';
import 'student_guide_screen.dart';
import '../core/app_state.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late final VoidCallback _listener;

  @override
  void initState() {
    super.initState();
    _listener = () {
      if (appState.currentTabIndex != _currentIndex) {
        setState(() {
          _currentIndex = appState.currentTabIndex;
        });
      }
    };
    appState.addListener(_listener);
  }

  @override
  void dispose() {
    appState.removeListener(_listener);
    super.dispose();
  }

  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const AssistantScreen(),
    const LecturerDirectoryScreen(),
    const BusScheduleScreen(),
    const StudentGuideScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          appState.setTabIndex(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.messageSquare), label: 'Assistant'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.users), label: 'Lecturers'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.bus), label: 'Bus'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.info), label: 'Guide'),
        ],
      ),
    );
  }
}
