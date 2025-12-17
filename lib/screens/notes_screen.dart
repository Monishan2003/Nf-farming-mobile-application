import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/api_service.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiNotes = await ApiService.getNotes();
      final parsed = apiNotes
          .whereType<Map>()
          .map((n) => Map<String, dynamic>.from(n))
          .toList();

      if (mounted) {
        setState(() => notes = parsed);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      return DateTime.parse(raw.toString()).toLocal().toString().split('.').first;
    } catch (_) {
      return '';
    }
  }

  void _showNoteDetail(Map<String, dynamic> note) {
    final createdAt = _formatDate(note['createdAt']);
    final updatedAt = _formatDate(note['updatedAt']);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                (note['title'] ?? 'Note').toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if ((note['category'] ?? '').toString().isNotEmpty)
                Chip(
                  label: Text((note['category'] ?? 'other').toString()),
                  backgroundColor: Colors.green.shade50,
                  side: BorderSide(color: Colors.green.shade200),
                ),
              if (createdAt.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Created: $createdAt', style: const TextStyle(color: Colors.grey)),
              ],
              if (updatedAt.isNotEmpty && updatedAt != createdAt) ...[
                const SizedBox(height: 4),
                Text('Updated: $updatedAt', style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 12),
              Text(
                (note['noteText'] ?? '').toString(),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        leading: const BackButton(color: AppColors.green),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: AppColors.green),
            onPressed: _loadNotes,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotes,
        child: _isLoading && notes.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 240),
                  Center(child: CircularProgressIndicator()),
                ],
              )
            : _error != null
                ? ListView(
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.redAccent),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadNotes,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : notes.isEmpty
                    ? ListView(
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Text(
                              'No Notes Yet',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          final created = _formatDate(note['createdAt']);
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                (note['title'] ?? 'Note').toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                (note['noteText'] ?? '').toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: created.isNotEmpty
                                  ? Text(
                                      created.split(' ').first,
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    )
                                  : null,
                              onTap: () => _showNoteDetail(note),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
