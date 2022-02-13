
class Note {

  String desc;
  DateTime timestamp = DateTime.now();

  Note(this.desc);

  void setDesc(String newDesc) {
    desc = newDesc;
  }

  void setTimestamp(DateTime dateTime) {
    timestamp = dateTime;
  }

  String _timesStringFormatter(int timeValue) {
    return (timeValue < 10 ? "0" : "") + timeValue.toString();
  }

  String timestampHour() {
    return _timesStringFormatter(timestamp.hour) + ":"
        + _timesStringFormatter(timestamp.minute);
  }

  String timestampDate() {
    return _timesStringFormatter(timestamp.day) + "/"
        + _timesStringFormatter(timestamp.month) + "/"
        + _timesStringFormatter(timestamp.year);
  }

}