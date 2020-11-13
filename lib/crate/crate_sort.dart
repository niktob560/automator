import 'package:flutter/material.dart';
import 'package:automator/misc.dart';
import 'package:automator/rest_api/api_service.dart';
import 'package:automator/rest_api/models.dart';

import 'package:automator/notes/notes.dart' as notes;
import 'package:automator/current/current.dart' as current;
import 'package:automator/later/later.dart' as later;
import 'package:automator/projects/projects.dart' as projects;
import 'package:automator/done/done.dart' as done;
import 'package:automator/calendar/calendar.dart' as calendar;
import 'package:automator/archive/archive.dart' as archive;
import 'package:automator/await/await.dart' as wait;

class SortingStatefulWidget extends StatefulWidget {
  SortingStatefulWidget({Key key}) : super(key: key);

  @override
  SortingStatefulWidgetState createState() => SortingStatefulWidgetState();
}

class SortingStatefulWidgetState extends State<SortingStatefulWidget> {
  var _state = 0;
  List<int> _prevStates = [];
  bool _isFinishing = false;
  Future<Record> _record;
  DateTime _date;
  TimeOfDay _time;
  String _executorErrorMessage,
      _finishCriteriaErrorMessage,
      _planErrorMessage,
      _firstStepErrorMessage,
      _noteErrorMessage;
  static const int stateAnyToDo = 0,
      stateIsMyTask = 1,
      stateIsNow = 2,
      stateIsOneStep = 3,
      stateIsEpsilonTime = 4,
      stateArchiveOrNote = 5,
      stateIsTimed = 6,
      stateProject = 7,
      stateDoIt = 8,
      stateAwait = 9,
      stateCurrentTask = 10,
      stateArchive = 11,
      stateNotes = 12,
      stateSetDeadline = 13,
      stateNotTimed = 14,
      stateProjectDone = 15,
      stateDone = 16,
      stateCurrentTaskDone = 17,
      stateArchiveDone = 18,
      stateNotesDone = 19,
      stateCalendarDone = 20,
      stateLaterDone = 21,
      stateAwaitDone = 22;

  TextEditingController _contr = TextEditingController();
  TextEditingController _planContr = TextEditingController();
  TextEditingController _criteriaContr = TextEditingController();
  TextEditingController _stepContr = TextEditingController();
  TextEditingController _executorContr = TextEditingController();

  _setState(int newState) async {
    var rec = await _record;
    _record = (() async => Record(_contr.text, id: rec.id, creationDate: rec.creationDate))();
    // (await _record).note = _contr.text;
    if (_contr.text.isEmpty) {
      setState(() {
        _noteErrorMessage = 'Can`t be empty';
      });
      return;
    } else if (_contr.text.length < 4) {
      setState(() {
        _noteErrorMessage = 'Must have at least 4 chars';
      });
      return;
    }
    setState(() {
      _noteErrorMessage = null;
      _prevStates.add(_state);
      _state = newState;
    });
  }

  _backState() {
    _date = null;
    _time = null;
    var s = _prevStates.last;
    _prevStates.remove(s);
    setState(() {
      _state = s;
    });
  }

  _finishState(int newState) async {
    if (_contr.text.isEmpty) {
      setState(() {
        _noteErrorMessage = 'Can`t be empty';
      });
      return;
    } else if (_contr.text.length < 4) {
      setState(() {
        _noteErrorMessage = 'Must have at least 4 chars';
      });
      return;
    }
    setState(() {
      _executorErrorMessage = null;
      _finishCriteriaErrorMessage = null;
      _planErrorMessage = null;
      _firstStepErrorMessage = null;
      _noteErrorMessage = null;
      _isFinishing = true;
    });
    var id = (await _record).id;
    var res;
    var msg;
    try {
      switch (newState) {
        case stateArchiveDone:
          res = await ApiService.makeArchive(id, newNote: _contr.text);
          break;
        case stateNotesDone:
          res = await ApiService.makeNote(id, newNote: _contr.text);
          break;
        case stateDone:
          res = await ApiService.makeDone(id, newNote: _contr.text);
          break;
        case stateCurrentTaskDone:
          res = await ApiService.makeCurrent(id, newNote: _contr.text);
          break;
        case stateLaterDone:
          res = await ApiService.makeLater(id, newNote: _contr.text);
          break;
        case stateAwaitDone:
          print('$_date $_time ${_executorContr.text}');
          if (_date == null) {
            msg = "Date must be set";
          } else if (_time == null) {
            msg = "Time must be set";
          } else if (_executorContr.text == null ||
              _executorContr.text.length == 0) {
            msg = "Executor must be set";
          } else {
            res = await ApiService.makeAwait(
                id,
                DateTime(_date.year, _date.month, _date.day, _time.hour,
                    _time.minute),
                _executorContr.text,
                newNote: _contr.text);
          }
          break;
        case stateProjectDone:
          var s = [_stepContr.text];
          res = await ApiService.makeProject(
              id, _criteriaContr.text, _planContr.text, s,
              newNote: _contr.text);
          break;
        case stateCalendarDone:
          print('$_date $_time ');
          if (_date == null) {
            msg = "Date must be set";
          } else if (_time == null) {
            msg = "Time must be set";
          } else {
            res = await ApiService.makeCalendar(
                id,
                DateTime(_date.year, _date.month, _date.day, _time.hour,
                    _time.minute),
                newNote: _contr.text);
          }
          break;
      }
    } catch (e) {
      print('$e');
    }
    _criteriaContr.clear();
    _executorContr.clear();
    _planContr.clear();
    _stepContr.clear();
    _date = null;
    _time = null;
    if (msg == null && (res == null || !res)) {
      print("Failed to send: query returned $res");
      msg =
          "Failed to send request" + (res != null ? "" : ": connection error");
    }
    if (msg != null) {
      setState(() {
        _isFinishing = false;
      });
      final snackBar = SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      );
      Scaffold.of(context).showSnackBar(snackBar);
      return;
    }
    setState(() {
      _prevStates.clear();
      _state = newState;
      _isFinishing = false;
    });
    _stateReset();
  }

  @override
  void initState() {
    super.initState();
    _record = ApiService.getLastCrateRecords();
  }

  _stateReset() async {
    _contr.text = (await _record).note;
    await sleep1();
    setState(() {
      _record = ApiService.getLastCrateRecords();
    });
    await _record;
    setState(() {
      _state = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _record,
      builder: (BuildContext context, AsyncSnapshot<Record> snapshot) {
        List<Widget> children = [
          Text(
            'Sort a record',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(
            height: 16,
          ),
        ];
        // if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasData) {
          children.addAll([
            TextField(
              decoration: getInputDecoration('Record', _noteErrorMessage),
              controller: _contr,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            ),
            Container(
              child: Center(
                  child: [
                YesNoStatelessWidget(
                  question: 'Any to do with this?',
                  yesFunction: () => _setState(stateIsMyTask),
                  noFunction: () => _setState(stateArchiveOrNote),
                ),
                YesNoStatelessWidget(
                  question: 'Is it my task?',
                  yesFunction: () => _setState(stateIsNow),
                  noFunction: () => _setState(stateAwait),
                ),
                YesNoStatelessWidget(
                  question: 'Now?',
                  yesFunction: () => _setState(stateIsOneStep),
                  noFunction: () => _setState(stateIsTimed),
                ),
                YesNoStatelessWidget(
                  question: 'One step?',
                  yesFunction: () => _setState(stateIsEpsilonTime),
                  noFunction: () => _setState(stateProject),
                ),
                YesNoStatelessWidget(
                  question: 'Can be done in a little of time?',
                  yesFunction: () => _setState(stateDoIt),
                  noFunction: () => _setState(stateCurrentTask),
                ),
                YesNoStatelessWidget(
                  question: 'Put to archive or notes?',
                  yesText: 'Archive',
                  yesFunction: () => _setState(stateArchive),
                  noText: 'Notes',
                  noFunction: () => _setState(stateNotes),
                ),
                YesNoStatelessWidget(
                  question: 'Has a deadline?',
                  yesFunction: () => _setState(stateSetDeadline),
                  noFunction: () => _setState(stateNotTimed),
                ),
                Column(
                  //Project
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      decoration: getInputDecoration(
                          'Finish criteria', _finishCriteriaErrorMessage),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _criteriaContr,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration:
                          getInputDecoration('A rough plan', _planErrorMessage),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _planContr,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: getInputDecoration(
                          'First step', _firstStepErrorMessage),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _stepContr,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                          child: Text(
                            'Done',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            print(
                                '${_criteriaContr.text} ${_planContr.text} ${_stepContr.text}');
                            setState(() {
                              _finishCriteriaErrorMessage = null;
                              _planErrorMessage = null;
                              _firstStepErrorMessage = null;
                            });
                            var valid = true;
                            setState(() {
                              if (_criteriaContr.text.length == 0) {
                                valid = false;
                                _finishCriteriaErrorMessage = 'Can`t be empty';
                              }
                              if (_planContr.text.length == 0) {
                                valid = false;
                                _planErrorMessage = 'Can`t be empty';
                              }
                              if (_stepContr.text.length == 0) {
                                valid = false;
                                _firstStepErrorMessage = 'Can`t be empty';
                              } else if (_stepContr.text.length < 4) {
                                valid = false;
                                _firstStepErrorMessage =
                                    'Must contain at least 4 chars';
                              }
                            });
                            if (valid) _finishState(stateProjectDone);
                          }),
                    )
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Do it!',
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Center(
                      child: Icon(Icons.double_arrow,
                          size: MediaQuery.of(context).size.width * 0.8),
                    ),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                          child: Text('Done',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24)),
                          color: Theme.of(context).accentColor,
                          onPressed: () => _finishState(stateDone)),
                    ),
                    const SizedBox(
                      height: 16,
                    )
                  ],
                ),
                Column(
                  //Await
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      decoration:
                          getInputDecoration('Executor', _executorErrorMessage),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _executorContr,
                    ),
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        child: DatePickerStatefulWidget('Execution date',
                            dateCallback: (d) => _date = d)),
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        child: TimePickerStatefulWidget('Execution time',
                            timeCallback: (t) => _time = t)),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      child: RaisedButton(
                          child: Text(
                            'Done',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Theme.of(context).accentColor,
                          onPressed: () => _executorContr.text.length > 0
                              ? _finishState(stateAwaitDone)
                              : setState(() {
                                  _executorErrorMessage =
                                      'Executor must be set';
                                })),
                    ),
                  ],
                ),
                Column(
                  //Current
                  children: [
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text('Add to current tasks'),
                          onPressed: () => _finishState(stateCurrentTaskDone),
                        )),
                  ],
                ),
                Column(
                  //Archive
                  children: [
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text('Add to archive'),
                          onPressed: () => _finishState(stateArchiveDone),
                        )),
                  ],
                ),
                Column(
                  //Notes
                  children: [
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text('Add to notes'),
                          onPressed: () => setState(() {
                            _finishState(stateNotesDone);
                          }),
                        )),
                  ],
                ),
                Column(
                  //Calendar
                  children: [
                    const SizedBox(height: 64),
                    Container(
                        width: double.infinity,
                        child: DatePickerStatefulWidget('Execution date',
                            dateCallback: (d) => _date = d)),
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        child: TimePickerStatefulWidget('Execution time',
                            timeCallback: (t) => _time = t)),
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        child: RaisedButton(
                          child: Text('Add on calendar'),
                          onPressed: () => _finishState(stateCalendarDone),
                        )),
                    const SizedBox(height: 32),
                  ],
                ),
                Container(
                    //Later
                    width: double.infinity,
                    child: Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: RaisedButton(
                          child: Text('Add to later tasks'),
                          onPressed: () => _finishState(stateLaterDone),
                        ))),
                IconTextWidget(
                    projects.meta.icon, 'Project added to current projects!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(done.meta.icon, 'Task done!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(
                    current.meta.icon, 'Task added to current tasks!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(archive.meta.icon, 'Record added to archive!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(notes.meta.icon, 'Record added to notes!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(calendar.meta.icon, 'Task added on calendar!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(later.meta.icon, 'Task added on later tasks!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(wait.meta.icon, 'Task added on await tasks!',
                    iconColor: Colors.white, textColor: Colors.white),
              ][_state]),
              width: double.infinity,
            ),
            snapshot.connectionState == ConnectionState.done && !_isFinishing
                ? Container()
                : Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ))
          ]);
          if (_prevStates.length > 0) {
            children.add(const SizedBox(height: 16));
            children.add(Container(
                width: double.infinity,
                child: RaisedButton(
                  child: Text(
                    'Back',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).accentColor,
                  onPressed: _backState,
                )));
          }
          _contr.text = snapshot.data.note;
        } else if (snapshot.hasError) {
          children.add(IconTextWidget(
            Icons.clear,
            'There is no records in crate',
            textSize: 24,
            iconColor: Theme.of(context).errorColor,
          ));
        } else {
          children.addAll([
            Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.width * 0.4,
                    child: CircularProgressIndicator())),
            SizedBox(
              height: 32,
            ),
            Center(
                child: Text(
              "Loading...",
              style: TextStyle(fontSize: 24),
            ))
          ]);
        }

        List<Widget> children_padded = [];
        children_padded.add(const SizedBox(height: 32));
        for (final i in children) {
          children_padded.add(Padding(
            padding: EdgeInsets.only(left: 32, right: 32),
            child: i,
          ));
        }
        children_padded.add(const SizedBox(height: 32));

        return Center(
            child: ListView(
          children: children_padded,
        ));
      },
    );
  }
}
