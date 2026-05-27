import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class StudentGuideScreen extends StatelessWidget {
  const StudentGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Guide'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGuideSection(
            context,
            'Campus Facilities',
            LucideIcons.building,
            'Learn about the library, sports complex, clinic, and other facilities available to you.',
          ),
          _buildGuideSection(
            context,
            'Registration Guide',
            LucideIcons.clipboardList,
            'Step-by-step instructions on course registration and fee payment.',
          ),
          _buildGuideSection(
            context,
            'Campus Survival Tips',
            LucideIcons.lightbulb,
            'Tips on managing your time, joining societies, and living in Mahallah.',
          ),
          _buildGuideSection(
            context,
            'Food & Prayer Places',
            LucideIcons.utensils,
            'Best places to eat around campus and locations of Musollas in faculties.',
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection(BuildContext context, String title, IconData icon, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryGreen, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(description, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: AppTheme.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
