import 'package:automator/misc.dart';
import 'package:flutter/cupertino.dart';

@immutable
class Record {
  String _note;
  DateTime _creationDate;
  int _id, _rootId;

  Record(this._note, {creationDate, id, rootId}) {
    _creationDate = creationDate;
    _id = id;
    _rootId = rootId;
  }

  get creationDate => _creationDate;

  get id => _id;

  get rootId => _rootId;

  String get note => _note;

  @override
  String toString() {
    return 'Record{note: $note, _creationDate: $_creationDate, _id: $_id, _rootId: $_rootId}';
  }

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record('${json['note']}',
        id: json['id'],
        rootId: json['root_id'],
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

class DeadlinedRecord extends Record {
  DateTime _deadline;

  DeadlinedRecord(note, this._deadline, {creationDate, id, rootId})
      : super(note, creationDate: creationDate, id: id, rootId: rootId);


  factory DeadlinedRecord.fromJson(Map<String, dynamic> json) {
    return DeadlinedRecord(
        json['note'],
        serverDateFormat
            .parse(json['deadline'])
            .add(DateTime.now().timeZoneOffset),
        creationDate: serverDateFormat
            .parse(json['creation_date'])
            .add(DateTime.now().timeZoneOffset),
        id: json['id'],
        rootId: json['root_id']
    );
  }

  @override
  String toString() {
    return 'DeadlinedRecord{_deadline: $_deadline, super: ${super.toString()}';
  }

  DateTime get deadline => _deadline;
}

class AwaitRecord extends DeadlinedRecord {
  String _executor;

  AwaitRecord(note, this._executor, deadline, {creationDate, id, rootId})
      : super(note, deadline, creationDate: creationDate, id: id, rootId: rootId);

  factory AwaitRecord.fromJson(Map<String, dynamic> json) {
    return AwaitRecord(
        json['note'],
        json['executor_info'],
        serverDateFormat
            .parse(json['deadline'])
            .add(DateTime.now().timeZoneOffset),
        creationDate: serverDateFormat
            .parse(json['creation_date'])
            .add(DateTime.now().timeZoneOffset),
        id: json['id'],
        rootId: json['root_id']
    );
  }

  @override
  String toString() {
    return 'AwaitRecord{_executor: $_executor, super: ${super.toString()}';
  }

  String get executor => _executor;
}