import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../core/theme.dart';

class BusScheduleScreen extends StatefulWidget {
  const BusScheduleScreen({super.key});

  @override
  State<BusScheduleScreen> createState() => _BusScheduleScreenState();
}

class _BusScheduleScreenState extends State<BusScheduleScreen> {
  late Timer _timer;
  int _simulationTick = 0;

  @override
  void initState() {
    super.initState();
    // Simulate live updates every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _simulationTick++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Schedule'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              child: Column(
                children: [
                  const Icon(LucideIcons.bus, size: 32, color: AppTheme.primaryGreen),
                  const SizedBox(height: 8),
                  Text(
                    'SHUTTLE BUS SERVICES',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '(MONDAY TO THURSDAY)',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1.5),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                        child: Text('TIME', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                        child: Text('ROUTE 1\nRuqayyah', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                        child: Text('ROUTE 2\nSalahuddin', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  ...MockData.busSchedules.map((entry) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Text(entry.time, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Center(child: Text(entry.route1, style: const TextStyle(fontSize: 14))),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                          child: Center(child: Text(entry.route2, style: const TextStyle(fontSize: 14))),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
