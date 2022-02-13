import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
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
            "Edit note", note.getDesc(), _editNote(note));
      }
    );
  }

  void _showRemoveNoteDialog(Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Remove note"),
          content: const Text("Are you sure you want to remove this note?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No")),
            TextButton(
                onPressed: () {
                  _removeNote(note);
                  Navigator.pop(context);
                },
                child: const Text("Yes")),
          ],
        );
      }
    );
  }

  _showChangeDateDialog(Note note) {
    List<int> date = [note.getTimestamp().year, note.getTimestamp().month, note.getTimestamp().day];
    List<int> hour = [note.getTimestamp().hour, note.getTimestamp().minute];
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Change note's date"),
            content: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: DateTimeFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.date_range),
                        labelText: 'Pick a new date',
                      ),
                      initialDate: DateTime(date[0], date[1], date[2]),
                      mode: DateTimeFieldPickerMode.date,
                      onDateSelected: (DateTime dateValue) {
                        date = [dateValue.year, dateValue.month, dateValue.day];
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: DateTimeFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.schedule),
                        labelText: 'Pick an hour',
                      ),
                      initialDate: note.getTimestamp(),
                      mode: DateTimeFieldPickerMode.time,
                      onDateSelected: (DateTime hourValue) {
                        hour = [hourValue.hour, hourValue.minute];
                      },
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () {
                    DateTime newTimestamp = DateTime(date[0], date[1], date[2], hour[0], hour[1]);
                    _changeNoteTimestamp(note, newTimestamp);
                    Navigator.pop(context);
                  },
                  child: const Text("Ok")),
            ],
          );
        }
    );
  }

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

  void _removeNote(Note note) {
    setState(() {
      _notes.remove(note);
    });
  }
  
  void _changeNoteTimestamp(Note note, DateTime date) {
    setState(() {
      note.setTimestamp(date);
    });
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
        subtitle: Text(nota.getDesc()),
        trailing: TextButton(
          onPressed: () {
            _showChangeDateDialog(nota);
          },
          child: Text(nota.timestampDate()),
        ),
        onTap: () {
          _showEditNoteDialog(nota);
        },
        onLongPress: () {
          _showRemoveNoteDialog(nota);
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
