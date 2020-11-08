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
      stateLaterDone = 21;

  TextEditingController _contr = TextEditingController();

  _setState(int newState) {
    setState(() {
      _prevStates.add(_state);
      _state = newState;
    });
  }

  _backState() {
    var s = _prevStates.last;
    _prevStates.remove(s);
    setState(() {
      _state = s;
    });
  }

  _finishState(int newState) async {
    setState(() {
      _isFinishing = true;
    });
    // String url = "/";
    var id = (await _record).id;
    var res;
    switch(newState) {
      case stateArchiveDone:
        res = await REST.ApiService.makeArchive(id);
        // url = url + "archive/make_archive?id=$id";
        break;
      case stateNotesDone:
        res = await REST.ApiService.makeNote(id);
        // url = url + "notes/make_note?id=$id";
        break;
      case stateDone:
        // url = url + "done/make_done?id=$id";
        break;
      case stateCurrentTaskDone:
        // url = url + "current/make_current?id=$id";
        break;
      case stateLaterDone:
        // url = url + "later/make_later?id=$id";
        break;
    }
    // url = HOST + "/api" + url;
    // try {
    //   var resp = await http.patch(url);
    //   print(resp);
    //   if (resp.statusCode != 200) {
    //     print(resp.statusCode);
    //     throw Exception(resp.body);
    //   }
    // }
    // catch (e) {
    if (res == null || !res) {
      setState(() {
        _isFinishing = false;
      });
      print("Failed to send!");
      final snackBar = SnackBar(
        content: Text("Failed to send request"),
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
              decoration: getInputDecoration('Record', null),
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
                      //Setup project
                      children: [
                        const SizedBox(height: 16),
                        TextField(
                          decoration: getInputDecoration('Finish criteria', null),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: getInputDecoration('A rough plan', null),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: getInputDecoration('First step', null),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
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
                              onPressed: () => _finishState(stateProjectDone)),
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
                      children: [
                        const SizedBox(height: 16),
                        TextField(
                          decoration: getInputDecoration('Executor', null),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                        const SizedBox(height: 32),
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
                              child: Text(
                                'Done',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Theme.of(context).accentColor,
                              onPressed: () => _finishState(stateProjectDone)),
                        ),
                      ],
                    ),
                    Column(
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
        (controller.position.pixels + (scrollExtent / 2)) >= controller.position.maxScrollExtent) {
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
      records = await REST.ApiService.getCrateRecords(offset: _allCrateRecords.length, limit: 10);
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
    var list = (await REST.ApiService.getCrateRecords(offset: _allCrateRecords.length, limit: 1));
    if (list.length == 0) return true;
    var last = list.elementAt(0);
    return last.id == _allCrateRecords[0].id ||
        last.id == _allCrateRecords[_allCrateRecords.length - 1].id;
  }

  Future<bool> hasNewElements() async {
    if (isLoading) return false;
    if (_allCrateRecords.length == 0) return true;
    var first = (await REST.ApiService.getCrateRecords(offset: 0, limit: 1)).elementAt(0);
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
