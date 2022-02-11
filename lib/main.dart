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
      title: 'Welcome to Flutter',
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

  final _notes = <Note>[Note("nota 1"), Note("nota 2"), Note("nota 3"), Note("nota 4")];
  final _biggerFont = const TextStyle(fontSize: 18);

  void addNewNote(Note note) {
    setState(() {
      _notes.insert(0, note);
    });
  }

  Widget _buildList() {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notes.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            children: [
              _buildRow(_notes[index]),
              const Divider(),
            ],
          );
        }
    );
  }

  Widget _buildRow(Note nota) {

    return Card(
        child: ListTile(
          title: Text(nota.timestampHour()),
          subtitle: Text(nota.desc),
          trailing: Text(nota.timestampDate()),
        ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Alert Dialog title"),
          content: const Text("Alert Dialog body"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Close"))
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
      ),
      body: _buildList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog();
        } ,
        child: const Icon(Icons.add),
      ),
    );
  }
}
