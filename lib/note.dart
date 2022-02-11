
class Note {

  String desc;
  DateTime timestamp = DateTime.now();

  Note(this.desc);

  String timestampHour() {
    return timestamp.hour.toString() + ":"
        + timestamp.minute.toString();
  }

  String timestampDate() {
    return timestamp.day.toString() + "/"
        + timestamp.month.toString() + "/"
        + timestamp.year.toString();
  }

}