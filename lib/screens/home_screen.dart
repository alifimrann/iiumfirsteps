import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IIUM First Steps'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                'assets/images/logo.jpeg',
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if logo not yet added
                  return const SizedBox(height: 120, child: Center(child: Text('Logo goes here')));
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome, New Student!',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore campus, find your way around, and get help.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.compass, color: AppTheme.white, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Campus Tour',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find your faculty and important places.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondaryGreen),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Important Contacts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildContactCard(context, 'Clinic', LucideIcons.stethoscope, '03-6421 4444'),
                _buildContactCard(context, 'Security', LucideIcons.shield, '03-6421 5555'),
                _buildContactCard(context, 'OSEM', LucideIcons.users, '03-6421 6666'),
                _buildContactCard(context, 'Counselling', LucideIcons.heartHandshake, '03-6421 7777'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, String title, IconData icon, String phone) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 28),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(phone, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
