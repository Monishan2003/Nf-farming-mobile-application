import 'package:flutter/material.dart';
import '../app_colors.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, String>> notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        leading: const BackButton(color: AppColors.green),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
      ),
      body: notes.isEmpty
          ? const Center(
              child: Text(
                'No Notes Yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      notes[index]['title'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      notes[index]['content'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditNoteScreen(
                            note: notes[index],
                            index: index,
                            onUpdate: (updatedNote) {
                              setState(() {
                                notes[index] = updatedNote;
                              });
                            },
                          ),
                        ),
                      );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          notes.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditNoteScreen(
                onAdd: (newNote) {
                  setState(() {
                    notes.add(newNote);
                  });
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class EditNoteScreen extends StatefulWidget {
  final Map<String, String>? note;
  final int? index;
  final Function(Map<String, String>)? onAdd;
  final Function(Map<String, String>)? onUpdate;

  const EditNoteScreen({this.note, this.index, this.onAdd, this.onUpdate, super.key});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  late bool _isEditing;
  String? _originalTitle;
  String? _originalContent;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      titleController.text = widget.note!['title'] ?? '';
      contentController.text = widget.note!['content'] ?? '';
      _originalTitle = titleController.text;
      _originalContent = contentController.text;
      _isEditing = false;
    } else {
      _isEditing = true;
    }
  }

  void saveNote() {
    final Map<String, String> note = {
      'title': titleController.text,
      'content': contentController.text,
    };

    if (widget.note == null) {
      widget.onAdd?.call(note);
    } else {
      widget.onUpdate?.call(note);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveNote,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              enabled: _isEditing,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: TextField(
                controller: contentController,
                readOnly: !_isEditing,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                  onPressed: _isEditing ? saveNote : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    if (_isEditing) {
                      if (widget.note != null) {
                        titleController.text = _originalTitle ?? '';
                        contentController.text = _originalContent ?? '';
                        _isEditing = false;
                      } else {
                        Navigator.pop(context);
                      }
                    } else {
                      _isEditing = true;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: Text(_isEditing ? 'Cancel' : (widget.note == null ? 'Close' : 'Edit')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
