// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'note.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Timestamped note taking app',
      home: NotesList(),
    );
  }
}

class NotesList extends StatefulWidget {
  const NotesList({Key? key}) : super(key: key);

  @override
  _NotesListState createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {

  final _notes = <Note>[Note("prueba")];
  final TextEditingController _newNoteDialogTextFieldController = TextEditingController();
  final TextEditingController _editNoteDialogTextFieldController = TextEditingController();


  void addNewNote(String description) {
    Note note = Note(description);
    setState(() {
      _notes.insert(0, note);
    });
  }

  Widget _buildList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notes.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildRow(_notes[index]);
        }
    );
  }

  Widget _buildRow(Note nota) {
    return Card(
      child: ListTile(
        title: Text(nota.timestampHour()),
        subtitle: Text(nota.desc),
        trailing: Text(nota.timestampDate()),
        onTap: () {
          _showEditNoteDialog(nota);
        },
      ),
    );
  }

  void _showNewNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("New note"),
          content: TextField(
            controller: _newNoteDialogTextFieldController,
            decoration: const InputDecoration(hintText: "Note description goes here"),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close")),
            TextButton(
                onPressed: () {
                  addNewNote(_newNoteDialogTextFieldController.text);
                  _newNoteDialogTextFieldController.text = "";
                  Navigator.pop(context);
                },
                child: const Text("Ok"),
            ),
          ],
        );
      }
    );
  }

  void _showEditNoteDialog(Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit note"),
          content: TextField(
            controller: _editNoteDialogTextFieldController,
            decoration: InputDecoration(hintText: note.desc),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close")),
            TextButton(
              onPressed: () {
                setState(() {
                  note.setDesc(_editNoteDialogTextFieldController.text);
                });
                _editNoteDialogTextFieldController.text = "";
                Navigator.pop(context);
              },
              child: const Text("Ok"),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewNoteDialog();
        } ,
        child: const Icon(Icons.add),
      ),
    );
  }
}
