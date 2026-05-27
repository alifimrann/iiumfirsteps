import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../core/app_state.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'assistant',
      'text': 'Hello! I am your IIUM campus guide. Ask me anything'
    }
  ];

  List<Lecturer> _allLecturers = [];
  List<Place> _allPlaces = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final lecturers = await FirestoreService().getLecturers();
      final places = await FirestoreService().getPlaces();
      if (mounted) {
        setState(() {
          _allLecturers = lecturers;
          _allPlaces = places;
        });
      }
    } catch (e) {
      debugPrint("Error fetching assistant data: $e");
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({'sender': 'user', 'text': userMessage});
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      final lower = userMessage.toLowerCase();

      String reply = "I couldn't find that information.";

      // =========================
      // 👨‍🏫 LECTURER SEARCH
      // =========================
      final foundLecturers = _allLecturers.where((lec) {
        final name = lec.name.toLowerCase();
        final queryWords = lower.split(RegExp(r'\W+')).where((w) => w.length > 2).toList();
        final stopWords = ['who', 'is', 'where', 'contact', 'dr', 'prof', 'teaches', 'teach', 'subject', 'course', 'for'];
        
        if (name.contains(lower) || lower.contains(name)) return true;

        for (final subject in lec.subjects) {
          final subjectLower = subject.toLowerCase();
          if (lower.contains(subjectLower) || subjectLower.contains(lower)) return true;
          
          final normalizedSubject = subjectLower.replaceAll(' ', '');
          final normalizedQuery = lower.replaceAll(' ', '');
          if (normalizedSubject.contains(normalizedQuery) || normalizedQuery.contains(normalizedSubject)) return true;

          final subjectWords = subjectLower.split(RegExp(r'\W+'));
          for (var word in queryWords) {
            if (stopWords.contains(word)) continue;
            if (subjectWords.contains(word)) return true;
          }
        }

        for (var word in queryWords) {
          if (stopWords.contains(word)) continue;
          if (name.contains(word)) return true;
        }
        return false;
      }).toList();

      if (foundLecturers.isNotEmpty) {
        setState(() {
          for (final lec in foundLecturers) {
            _messages.add({
              'sender': 'assistant',
              'text': "Here is the information for ${lec.name}:",
              'lecturer': lec,
            });
          }
        });
        return;
      }

      // =========================
      // 📍 CAMPUS PLACE SEARCH
      // =========================
      final foundPlaces = _allPlaces.where((place) {
        final name = place.name.toLowerCase();
        
        final RegExp abbrevRegex = RegExp(r'\(([^)]+)\)');
        final match = abbrevRegex.firstMatch(name);
        String abbrev = '';
        if (match != null) {
          abbrev = match.group(1)!.toLowerCase();
        }

        if (name.contains(lower) || lower.contains(name)) return true;
        if (abbrev.isNotEmpty && lower.contains(abbrev)) return true;
        
        final queryWords = lower.split(RegExp(r'\W+')).where((w) => w.length > 2).toList();
        for (var word in queryWords) {
          if (name.contains(word) || (abbrev.isNotEmpty && abbrev == word)) return true;
        }
        return false;
      }).toList();

      if (foundPlaces.isNotEmpty) {
        final place = foundPlaces.first;
        setState(() {
          _messages.add({
            'sender': 'assistant',
            'text': "I found ${place.name}.",
            'place': place,
          });
        });
        return;
      }

      // =========================
      // 📌 SPECIAL KEYWORDS
      // =========================
      else if (lower.contains("osem")) {
        reply = "OSEM contact: 03-6421 6666.";
      } else if (lower.contains("clinic")) {
        reply =
            "IIUM Clinic is open 8am–5pm. Contact: 03-6421 4444.";
      } else if (lower.contains("bus")) {
        reply =
            "Campus buses operate daily. Check bus schedule in the app.";
      } else if (lower.contains("food") || lower.contains("cafe")) {
        reply =
            "Cafes are available in every Kulliyyah and Mahallah.";
      }

      setState(() {
        _messages.add({'sender': 'assistant', 'text': reply});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Assistant'),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.primaryGreen : AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.85,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text']!,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (msg['lecturer'] != null)
                          _buildLecturerSnippet(context, msg['lecturer'] as Lecturer),
                        if (msg['place'] != null)
                          _buildPlaceSnippet(context, msg['place'] as Place),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // =========================
          // INPUT BOX
          // =========================
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about lecturers or places...',
                      filled: true,
                      fillColor: AppTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen,
                  child: IconButton(
                    icon: const Icon(
                      LucideIcons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLecturerSnippet(BuildContext context, Lecturer lecturer) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: lecturer.imageUrl.startsWith('http')
                    ? NetworkImage(lecturer.imageUrl)
                    : AssetImage(lecturer.imageUrl) as ImageProvider,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lecturer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(lecturer.department, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Subjects: ${lecturer.subjects.join(", ")}', style: const TextStyle(fontSize: 13)),
          Text('Office: ${lecturer.office}', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                appState.selectLecturerOnMap(lecturer);
              },
              icon: const Icon(LucideIcons.mapPin),
              label: const Text('Show on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceSnippet(BuildContext context, Place place) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(place.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(place.description, style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                appState.selectPlaceOnMap(place);
              },
              icon: const Icon(LucideIcons.mapPin),
              label: const Text('Show on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: AppTheme.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}