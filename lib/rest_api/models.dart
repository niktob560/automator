import 'package:automator/misc.dart';

class Record {
  String _note;
  DateTime _creationDate;
  int _id;

  Record(this._note, {creationDate, id}) {
    _creationDate = creationDate;
    _id = id;
  }

  DateTime get creationDate => _creationDate;
  String get note => _note;
  int get id => _id;

  set note(String value) {
    _note = value;
  }

  @override
  String toString() {
    return 'CrateRecord{_note: $_note, _creationDate: $_creationDate, _id: $_id}';
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record('${json['note']}',
        id: json['id'],
        creationDate: serverDateFormat
            .parse(json['creation_date'])
            .add(DateTime.now().timeZoneOffset));
  }
}
