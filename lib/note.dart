
class Note {

  String _desc;
  DateTime _timestamp = DateTime.now();

  Note(this._desc);

  /*
    Setters
  */

  void setDesc(String newDesc) {
    _desc = newDesc;
  }

  void setTimestamp(DateTime dateTime) {
    _timestamp = dateTime;
  }

  /*
    Getters
  */

  String getDesc() {
    return _desc;
  }

  DateTime getTimestamp() {
    return _timestamp;
  }

  /*
    Timestamp string formatters
  */


  String _timesStringFormatter(int timeValue) {
    return (timeValue < 10 ? "0" : "") + timeValue.toString();
  }

  String timestampHour() {
    return _timesStringFormatter(_timestamp.hour) + ":"
        + _timesStringFormatter(_timestamp.minute);
  }

  String timestampDate() {
    return _timesStringFormatter(_timestamp.day) + "/"
        + _timesStringFormatter(_timestamp.month) + "/"
        + _timesStringFormatter(_timestamp.year);
  }

}