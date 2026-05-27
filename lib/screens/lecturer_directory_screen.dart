import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../core/theme.dart';

class LecturerDirectoryScreen extends StatefulWidget {
  const LecturerDirectoryScreen({super.key});

  @override
  State<LecturerDirectoryScreen> createState() => _LecturerDirectoryScreenState();
}

class _LecturerDirectoryScreenState extends State<LecturerDirectoryScreen> {
  String _searchQuery = '';
  List<Lecturer> _allLecturers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLecturers();
  }

  Future<void> _fetchLecturers() async {
    try {
      final lecturers = await FirestoreService().getLecturers();
      if (mounted) {
        setState(() {
          _allLecturers = lecturers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error fetching lecturers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLecturers = _allLecturers.where((l) {
      final query = _searchQuery.toLowerCase();
      return l.name.toLowerCase().contains(query) || 
             l.department.toLowerCase().contains(query) ||
             l.subjects.any((s) => s.toLowerCase().contains(query));
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Directory'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search name or department...',
                prefixIcon: const Icon(LucideIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppTheme.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredLecturers.length,
              itemBuilder: (context, index) {
                final lecturer = filteredLecturers[index];
                return GestureDetector(
                  onTap: () => _showLecturerProfile(context, lecturer),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: lecturer.imageUrl.startsWith('http')
                                ? NetworkImage(lecturer.imageUrl)
                                : AssetImage(lecturer.imageUrl) as ImageProvider,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lecturer.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(lecturer.department, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryGreen)),
                                const SizedBox(height: 8),
                                _buildInfoRow(context, LucideIcons.book, 'Subjects: ${lecturer.subjects.join(", ")}'),
                              ],
                            ),
                          ),
                          const Icon(LucideIcons.chevronRight, color: AppTheme.textLight),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLecturerProfile(BuildContext context, Lecturer lecturer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: lecturer.imageUrl.startsWith('http')
                    ? NetworkImage(lecturer.imageUrl)
                    : AssetImage(lecturer.imageUrl) as ImageProvider,
              ),
              const SizedBox(height: 16),
              Text(lecturer.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
              const SizedBox(height: 4),
              Text(lecturer.department, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppTheme.primaryGreen)),
              const Divider(height: 32),
              if (lecturer.telephone != null)
                _buildInfoRow(context, LucideIcons.phone, lecturer.telephone!),
              const SizedBox(height: 12),
              _buildInfoRow(context, LucideIcons.mail, lecturer.email),
              const SizedBox(height: 12),
              _buildInfoRow(context, LucideIcons.mapPin, lecturer.office),
              const SizedBox(height: 12),
              _buildInfoRow(context, LucideIcons.book, 'Subjects: ${lecturer.subjects.join(", ")}'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Profile'),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      }
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textLight),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
