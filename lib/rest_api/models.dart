import 'package:intl/intl.dart';

class CrateRecord {
  String _note;
  DateTime _creationDate;
  int _id;

  CrateRecord(this._note, {creationDate, id}) {
    _creationDate = creationDate;
    _id = id;
  }

  DateTime get creationDate => _creationDate;
  String get note => _note;
  int get id => _id;

  @override
  String toString() {
    return 'CrateRecord{_note: $_note, _creationDate: $_creationDate, _id: $_id}';
  }
}