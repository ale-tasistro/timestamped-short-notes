
class Note {

  String desc;
  DateTime timestamp = DateTime.now();

  Note(this.desc);

  void setDesc(String newDesc) {
    desc = newDesc;
  }

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