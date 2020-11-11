import 'package:automator/misc.dart';

class Record {
  String note;
  DateTime _creationDate;
  int _id, _rootId;

  Record(this.note, {creationDate, id, rootId}) {
    _creationDate = creationDate;
    _id = id;
    _rootId = rootId;
  }

  get creationDate => _creationDate;
  get id => _id;
  get rootId => _rootId;


  @override
  String toString() {
    return 'Record{note: $note, _creationDate: $_creationDate, _id: $_id, _rootId: $_rootId}';
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record('${json['note']}',
        id: json['id'],
        rootId: json['rootId'], //TODO: check token
        creationDate: serverDateFormat
            .parse(json['creation_date'])
            .add(DateTime.now().timeZoneOffset));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Record && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
