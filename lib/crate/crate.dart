import 'dart:convert';

import 'package:flutter/material.dart';
import '../misc.dart';
import 'package:automator/rest_api/api_service.dart' as REST;
import 'package:automator/rest_api/models.dart';
import 'package:automator/day_night_gradients.dart';

class SortingStatefulWidget extends StatefulWidget {
  SortingStatefulWidget({Key key}) : super(key: key);

  @override
  SortingStatefulWidgetState createState() => SortingStatefulWidgetState();
}

class SortingStatefulWidgetState extends State<SortingStatefulWidget> {
  var _state = 0;
  GlobalKey<DatePickerStatefulWidgetState> _datePickerKey = GlobalKey();
  List<int> _prevStates = [];
  bool _isFinishing = false;
  Future<Record> _record;
  DateTime _date;
  TimeOfDay _time;
  Set<String> _projectSteps = Set();
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

  _setState(int newState) {
    setState(() {
      _prevStates.add(_state);
      _state = newState;
    });
  }

  _backState() {
    _date = null;
    _time = null;
    _projectSteps = Set();
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
    var oldNote = (await _record).note;
    var res;
    var msg;
    try {
      switch (newState) {
        case stateArchiveDone:
          if (_contr.text != oldNote)
            res = await REST.ApiService.makeArchive(id, newNote: _contr.text);
          else
            res = await REST.ApiService.makeArchive(id);
          break;
        case stateNotesDone:
          if (_contr.text != oldNote)
            res = await REST.ApiService.makeNote(id, newNote: _contr.text);
          else
            res = await REST.ApiService.makeNote(id);
          break;
        case stateDone:
          if (_contr.text != oldNote)
            res = await REST.ApiService.makeDone(id, newNote: _contr.text);
          else
            res = await REST.ApiService.makeDone(id);
          break;
        case stateCurrentTaskDone:
          if (_contr.text != oldNote)
            res = await REST.ApiService.makeCurrent(id, newNote: _contr.text);
          else
            res = await REST.ApiService.makeCurrent(id);
          break;
        case stateLaterDone:
          if (_contr.text != oldNote)
            res = await REST.ApiService.makeLater(id, newNote: _contr.text);
          else
            res = await REST.ApiService.makeLater(id);
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
            res = await REST.ApiService.makeAwait(
                id,
                DateTime(_date.year, _date.month, _date.day, _time.hour,
                    _time.minute),
                _executorContr.text);
          }
          break;
        case stateProjectDone:
          var s = [_stepContr.text];
          res = await REST.ApiService.makeProject(
              id, _criteriaContr.text, _planContr.text, s);
          break;
      }
    } catch (e) {
      print('$e');
    }
    if (msg == null && (res == null || !res)) {
      print("Failed to send: query returned $res");
      msg = "Failed to send request" + (res != null ? "" : ": server error");
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
    _fetchRecord();
  }

  @override
  void initState() {
    super.initState();
    _record = REST.ApiService.getLastCrateRecords();
  }

  _fetchRecord() {
    _stateResetter();
  }

  Future<void> _stateResetter() async {
    await sleep1();
    setState(() {
      _record = REST.ApiService.getLastCrateRecords();
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
                        child: DatePickerStatefulWidget('Execution date')),
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        child: TimePickerStatefulWidget('Execution time')),
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
                    Icons.list_alt, 'Project added to current projects!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(Icons.done, 'Task done!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(Icons.timelapse, 'Task added to current tasks!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(
                    Icons.archive_rounded, 'Record added to archive!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(Icons.edit, 'Record added to notes!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(Icons.calendar_today, 'Task added on calendar!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(Icons.timelapse, 'Task added on later tasks!',
                    iconColor: Colors.white, textColor: Colors.white),
                IconTextWidget(
                    Icons.accessibility, 'Task added on await tasks!',
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

class AllCrateStatefulWidget extends StatefulWidget {
  AllCrateStatefulWidget({Key key}) : super(key: key);

  @override
  AllCrateStatefulWidgetState createState() => AllCrateStatefulWidgetState();
}

class AllCrateStatefulWidgetState extends State<AllCrateStatefulWidget> {
  ScrollController controller;
  final _allCrateRecords = <Record>[];
  bool failed = false;
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = false;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  double scrollExtent = 0;

  @override
  void initState() {
    super.initState();
    startLoader();
    controller = new ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void _scrollListener() {
    if (scrollExtent == 0) {
      scrollExtent = controller.position.maxScrollExtent;
    }
    if (!failed &&
        (controller.position.pixels + (scrollExtent / 2)) >=
            controller.position.maxScrollExtent) {
      startLoader();
    }
  }

  startLoader() {
    print('StartLoader, loading: $isLoading');
    if (failed || isLoading) return;
    setState(() {
      isLoading = true;
      _loadData();
    });
  }

  Future<void> _loadData() async {
    print('_loadData');
    var records;
    try {
      records = await REST.ApiService.getCrateRecords(
          offset: _allCrateRecords.length, limit: 10);
    } catch (e) {
      print('Error');
      setState(() {
        failed = true;
      });
    }
    if (!failed) {
      setState(() {
        isLoading = false;
        _allCrateRecords.addAll(records);
        _allCrateRecords.sort((a, b) => b.id.compareTo(a.id));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: failed
            ? IconTextWidget(
                Icons.clear,
                'There is no records in crate',
                textSize: 24,
                iconColor: Theme.of(context).errorColor,
              )
            : Stack(
                children: <Widget>[
                  _buildSuggestions(),
                ],
              ));
  }

  Widget _buildRow(Record record) {
    final int hour = record.creationDate.hour % 24;
    final bool isDay = hour > 10 && hour < 16;
    return Container(
        decoration: BoxDecoration(gradient: dayNightGradient[hour]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: Text(
                record.note,
                style: TextStyle(
                    fontSize: 18.0, color: isDay ? Colors.white : Colors.white),
              ),
              subtitle: Text(
                userDateTimeFormat.format(record.creationDate),
                style: TextStyle(
                    fontSize: 12.0,
                    color: isDay ? Colors.white70 : Colors.white70),
              ),
              onTap: () {
                //TODO: open details
              },
            ),
            Divider(),
          ],
        ));
  }

  Future<void> _refresh() async {
    setState(() {
      _allCrateRecords.clear();
      isLoading = false;
      startLoader();
    });
  }

  Widget _buildSuggestions() {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: ListView.builder(
            padding: const EdgeInsets.all(0),
            // The itemBuilder callback is called once per suggested word pairing,
            // and places each suggestion into a ListTile row.
            // For even rows, the function adds a ListTile row for the word pairing.
            // For odd rows, the function adds a Divider widget to visually
            // separate the entries. Note that the divider may be difficult
            // to see on smaller devices.
            controller: controller,
            itemCount: _allCrateRecords.length + 1,
            physics: const AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              var s = _allCrateRecords.length;
              print('Building $i from $s');
              // Add a one-pixel-high divider widget before each row in theListView.
              // if (i == _allCrateRecords.length && !isLoading) {
              //   _checkForALater();
              // }
              return i < _allCrateRecords.length
                  ? _buildRow(_allCrateRecords[i])
                  : _loader();
            }));
  }

  Widget _loader() {
    return isLoading
        ? Align(
            child: Container(
              width: 70.0,
              height: 70.0,
              child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Center(child: CircularProgressIndicator())),
            ),
            alignment: FractionalOffset.bottomCenter,
          )
        : SizedBox(
            width: 0.0,
            height: 0.0,
          );
  }

  Future<bool> isLastElemLoaded() async {
    if (isLoading) return true;
    if (_allCrateRecords.length == 0) return false;
    var list = (await REST.ApiService.getCrateRecords(
        offset: _allCrateRecords.length, limit: 1));
    if (list.length == 0) return true;
    var last = list.elementAt(0);
    return last.id == _allCrateRecords[0].id ||
        last.id == _allCrateRecords[_allCrateRecords.length - 1].id;
  }

  Future<bool> hasNewElements() async {
    if (isLoading) return false;
    if (_allCrateRecords.length == 0) return true;
    var first = (await REST.ApiService.getCrateRecords(offset: 0, limit: 1))
        .elementAt(0);
    return first.id != _allCrateRecords[0].id &&
        first.id != _allCrateRecords[_allCrateRecords.length - 1].id;
  }
}

// class CrateRecord {
//   final int id;
//   final String note;
//   final DateTime creationDate;
//
//   CrateRecord({this.id, this.note, this.creationDate});
//
//   factory CrateRecord.fromJson(Map<String, dynamic> json) {
//     return CrateRecord(
//         id: json['id'],
//         note: json['note'],
//         creationDate: serverDateFormat
//             .parse(json['creation_date'])
//             .add(DateTime.now().timeZoneOffset));
//   }
//
//   Map<String, dynamic> toJson() {
//     var dat = serverDateFormat.format(creationDate);
//     return jsonDecode('{"id": $id, "note": "$note", "creaton_date": $dat}');
//   }
// }

Future<Record> fetchRecord(int id) async {
  // final http.Response response = await http.get(
  //   '$HOST/api/crate/get_record?id=$id',
  //   headers: <String, String>{
  //     'Content-Type': 'charset=UTF-8',
  //   },
  // );
  // if (response.statusCode == 200)
  //   return CrateRecord.fromJson(jsonDecode(response.body));
  // else
  //   throw Exception('Failed to load crate record with an id $id');
  return null;
}

// Future<CrateRecord> fetchLastCrateRecord() async {
//   return (await fetchRecords(0, 1)).elementAt(0);
// }

// Future<Set<CrateRecord>> fetchRecords(int offset, int limit) async {
// print('Fetch records limit $limit offset $offset');
// final http.Response response = await http.get(
//   '$HOST/api/crate/get_records?offset=$offset&limit=$limit',
//   headers: <String, String>{
//     'Content-Type': 'charset=UTF-8',
//   },
// );
// if (response.statusCode == 200) {
//   Set<CrateRecord> ret = Set<CrateRecord>();
//   for (final i in jsonDecode(response.body)) {
//     print('Fetching $i');
//     ret.add(CrateRecord.fromJson(i));
//   }
//   return ret;
// } else {
//   var rb = response.body;
//   throw Exception(
//       'Failed to load crate record limit $limit offset $offset: $rb');
// }
//   // return Set();
// }

// Future<bool> createCrateRecord(String note) async {
//   return REST.ApiService.postCrate(note);
//   // final http.Response response = await http.post(
//   //   '$HOST/api/crate/post_record',
//   //   headers: <String, String>{
//   //     'Content-Type': 'application/json; charset=UTF-8',
//   //   },
//   //   body: jsonEncode(<String, String>{
//   //     'note': note,
//   //   }),
//   // );
//   // return response;
// }
