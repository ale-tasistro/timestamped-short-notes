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

  final _notes = <Note>[Note("test")];
  final TextEditingController _newNoteDialogTextFieldController = TextEditingController();
  final TextEditingController _editNoteDialogTextFieldController = TextEditingController();

  /*
    Note adding and editing functions to pass as parameters to text field dialog function
  */

  void _addNewNote(String description) {
    Note note = Note(description);
    setState(() {
      _notes.insert(0, note);
    });
  }

  void Function(String) _editNote(Note note) {
    return (desc) => {
      setState(() {
        note.setDesc(desc);
      })
    };
  }

  /*
    Dialog rendering functions
  */

  Widget _textFieldDialog(TextEditingController controller,
      String title, String hint, void Function(String) okFunction) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close")),
        TextButton(
          onPressed: () {
            okFunction(controller.text);
            controller.text = "";
            Navigator.pop(context);
          },
          child: const Text("Ok"),
        ),
      ],
    );
  }

  void _showNewNoteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _textFieldDialog(_newNoteDialogTextFieldController,
            "New note", "Note description goes here", _addNewNote);
      }
    );
  }

  void _showEditNoteDialog(Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return  _textFieldDialog(_editNoteDialogTextFieldController,
            "Edit note", note.desc, _editNote(note));
      }
    );
  }

  /*
    Note tile and list rendering functions
  */

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

  /*
    Main build function
  */

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
