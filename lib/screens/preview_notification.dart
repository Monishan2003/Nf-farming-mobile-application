import 'package:flutter/material.dart';
import 'notes_screen.dart';

void main() => runApp(const PreviewNotesApp());

class PreviewNotesApp extends StatelessWidget {
  const PreviewNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Preview Notes',
      debugShowCheckedModeBanner: false,
      home: const NotesScreen(),
    );
  }
}
