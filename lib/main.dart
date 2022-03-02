import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'note.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'YANTA',
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

  List<Note> _notes = [];
  final TextEditingController _newNoteDialogTextFieldController = TextEditingController();
  final TextEditingController _editNoteDialogTextFieldController = TextEditingController();

  /*
    AppBar rendering functions
  */

  AppBar _appBar() {
    return AppBar(
      title: const Text('YANTA'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.print),
          tooltip: 'Export Notes to PDF',
          onPressed: () => _toPdf(_notes),
        )],
    );
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
            "Edit note", note.getDesc, _editNote(note));
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

  void _showChangeDateDialog(Note note) {
    List<int> date = [note.getTimestamp.year, note.getTimestamp.month, note.getTimestamp.day];
    List<int> hour = [note.getTimestamp.hour, note.getTimestamp.minute];
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
                      initialDate: note.getTimestamp,
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
    Note manipulation functions
  */

  void _addNewNote(String description) {
    Note note = Note(description);
    setState(() {
      _sortedInsert(note);
    });
    _saveItems();
  }

  void Function(String) _editNote(Note note) {
    return (desc) => {
      setState(() {
        note.setDesc = desc;
      }),
      _saveItems()
    };
  }

  void _removeNote(Note note) {
    setState(() {
      _notes.remove(note);
    });
    _updateNoteListOrder();
    _saveItems();
  }
  
  void _changeNoteTimestamp(Note note, DateTime date) {
    setState(() {
      note.setTimestamp = date;
    });
    _updateNoteListOrder();
    _saveItems();
  }

  /*
    Note List manipulation functions
  */

  void _updateNoteListOrder() {
    setState(() {
      _notes.sort((a, b) => b.compareTimestampTo(a));
    });
  }

  void _sortedInsert(Note note) {
    int i = 0;
    bool foundPlace = false;
    while(i < _notes.length && !foundPlace) {
      if (_notes[i].compareTimestampTo(note) > 0) {
        // the note in place i of the list has a later timestamp
        // than the one being inserted
        i++;
      } else {
        // the note in place i of the list has either the same or
        // an earlier timestamp than the one being inserted
        foundPlace = true;
      }
    }
    _notes.insert(i, note);
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
        subtitle: Text(nota.getDesc),
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
    Local storage functions
  */

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localDataFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }

  Future<String> _readContent() async {
    try {
      final file = await _localDataFile;
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      throw 'Error!';
    }
  }

  // Fetch content from the json file
  Future<void> _readJson() async {
    final String response = await _readContent();
    if (response.isNotEmpty) {
      final data = await json.decode(response);
      var jsonList = List<Map<String,dynamic>>.from(data["notes"]);
      setState(() {
        _notes = List<Note>.from(jsonList.map((e) => Note.fromJson(e)));
      });
    }
  }

  Future<File> _saveContent(String content) async {
    final file = await _localDataFile;
    // delete file before writing to avoid duplicating data?
    return file.writeAsString(content);
  }

  Future<File> _saveItems() {
    String encoded = json.encode({'notes':_notes});
    return _saveContent(encoded);
  }

  @override
  void initState() {
    super.initState();
    _readJson();
  }

  /*
    Exporting functions
  */

  List<Map<String, dynamic>> _noteListGroupByDate(List<Note> list) {
    List<Map<String, dynamic>> dateLists = [];
    if (list.isNotEmpty) {
      int fin = list.length;
      int index = 0;
      Note currentNote = list.elementAt(index);
      String lastDate = currentNote.timestampDate();
      List<Note> noteList = [];
      while (index < fin) {
        currentNote = list.elementAt(index);
        String currentDate = currentNote.timestampDate();
        if (lastDate == currentDate) {
          noteList.add(currentNote);
        } else {
          Map<String, dynamic> newDateList = {'date':lastDate, 'list':noteList};
          dateLists.add(newDateList);
          lastDate = currentDate;
          noteList = [currentNote];
        }
        index++;
      }
      Map<String, dynamic> newDateList = {'date':lastDate, 'list':noteList};
      dateLists.add(newDateList);
    }
    return dateLists;
  }

  String _formatGroupedNoteList(List<Map<String, dynamic>> list) {
    const divBar =
        "-------------------------------------------------------------------------------------------------------";
    String content = "";
    for(int i = 0; i < list.length; i++) {
      Map<String, dynamic> current = list.elementAt(i);
      content += current['date'] + '\n';
      List<Note> currentList = List<Note>.from(current['list']);
      for(int j = currentList.length-1; j >= 0; j--) {
        Note currentNote = currentList.elementAt(j);
        content += currentNote.timestampHour() + " - " + currentNote.getDesc + '\n';
      }
      content += divBar + '\n';
    }
    return content;
  }

  _toPdf(List<Note> list) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Text(_formatGroupedNoteList(_noteListGroupByDate(list)), style: const pw.TextStyle(fontSize: 14));// Center
        })
    ); // Page
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }


  /*
    Main build function
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
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
