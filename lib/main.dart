import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:morpheus/morpheus.dart';

final String HOST = 'http://192.168.1.66:8000';

//final String HOST = 'https://gtd-nobodyhomie.ddns.net';

void main() => runApp(MyApp());

/// This is the main application widget.
const String _title = 'Automat';

Theme theme;

final DateFormat serverDateFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ"),
    userDateTimeFormat = DateFormat("dd.MM.yyyy HH:mm"),
    userDateFormat = DateFormat("dd.MM.yyyy");

final TimeOfDayFormat userTimeFormat = TimeOfDayFormat.HH_colon_mm;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData td = ThemeData.dark().copyWith(
        accentColor: dayNightGradient[7].colors[0],
        primaryColor: dayNightGradient[6].colors[0],
        backgroundColor: dayNightGradient[1].colors[1],
        dialogBackgroundColor: dayNightGradient[0].colors[1],
        scaffoldBackgroundColor: dayNightGradient[1].colors[1],
        buttonColor: dayNightGradient[7].colors[0],
        secondaryHeaderColor: dayNightGradient[6].colors[0],
        splashColor: dayNightGradient[0].colors[1],
        cardColor: dayNightGradient[0].colors[0],
        highlightColor: dayNightGradient[6].colors[0],
        buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: dayNightGradient[7].colors[0],
            textTheme: ButtonTextTheme.primary));
    return MaterialApp(
        title: _title,
        color: Colors.black,
        home: RootStatefulWidget(),
        theme: td);
  }
}

InputDecoration getInputDecoration(String labelText, String errorText) {
  return InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
          color: dayNightGradient[7].colors[0], style: BorderStyle.solid),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
          color: dayNightGradient[7].colors[0], style: BorderStyle.solid),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
          color: dayNightGradient[7].colors[0], style: BorderStyle.solid),
    ),
    labelText: labelText,
    errorText: errorText,
    hintStyle: TextStyle(color: Colors.white60),
    labelStyle: TextStyle(color: dayNightGradient[7].colors[0]),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: Colors.white),
    ),
  );
}

class RootStatefulWidget extends StatefulWidget {
  RootStatefulWidget({Key key}) : super(key: key);

  @override
  _RootStatefulWidgetState createState() => _RootStatefulWidgetState();
}

class _RootStatefulWidgetState extends State<RootStatefulWidget> {
  Widget mainWidget = _MainStatefulWidget();

  Future<Widget> getFirstScreen() {}

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_title),
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Text(
                  _title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.add_box,
                  color: Colors.white60,
                ),
                title: Text(
                  'Main',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    mainWidget = _MainStatefulWidget();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.now_widgets,
                  color: Colors.white60,
                ),
                title: Text(
                  'Now',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    mainWidget = _CurrentTasksStatefulWidget();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Colors.white60,
                ),
                title: Text(
                  'Calendar',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    mainWidget = _CalendarStatefulWidget();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.av_timer,
                  color: Colors.white60,
                ),
                title: Text(
                  'Later',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    mainWidget = _LaterStatefulWidget();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.list,
                  color: Colors.white60,
                ),
                title: Text(
                  'Projects',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    mainWidget = _ProjectsStatefulWidget();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.timelapse,
                  color: Colors.white60,
                ),
                title: Text(
                  'Await',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    mainWidget = _AwaitStatefulWidget();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.note,
                  color: Colors.white60,
                ),
                title: Text(
                  'Notes',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    mainWidget = _NotesStatefulWidget();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.archive,
                  color: Colors.white60,
                ),
                title: Text(
                  'Archive',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    mainWidget = _ArchiveStatefulWidget();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        ),
      ),
      body: mainWidget,
    );
  }
}

class _MainStatefulWidget extends StatefulWidget {
  _MainStatefulWidget({Key key}) : super(key: key);

  @override
  _MainStatefulWidgetState createState() => _MainStatefulWidgetState();
}

class _MainStatefulWidgetState extends State<_MainStatefulWidget> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final TextEditingController _controller = TextEditingController();
  bool _progressBarActive = false;
  bool _crateCreateValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: MorpheusTabView(
        child: Padding(
          child: Center(
              child: [
            Center(
              child: ListView(
                padding: const EdgeInsets.only(right: 32, left: 32),
                children: [
                  const SizedBox(height: 32),
                  Text(
                    'Add a record',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  TextField(
                    decoration: getInputDecoration('Record',
                        _crateCreateValid ? null : 'Record Can\'t Be Empty'),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    controller: _controller,
                  ),
                  const SizedBox(height: 16),
                  RaisedButton(
                    color: Theme.of(context).accentColor,
                    child: Text(
                      'Add',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      var message;
                      try {
                        setState(() {
                          if (_controller.text.isEmpty) {
                            _crateCreateValid = false;
                          } else {
                            _crateCreateValid = true;
                          }
                        });
                        if (!_crateCreateValid) return;
                        setState(() {
                          _progressBarActive = true;
                        });
                        var r = await createCrateRecord(_controller.text);
                        if (r.statusCode == 200 &&
                            jsonDecode(r.body)['code'] == 0) {
                          message = 'Successfuly created';
                          _controller.text = '';
                        } else
                          message = 'An error occured';
                      } catch (e) {
                        message = 'No connection to the server';
                      }
                      setState(() {
                        _progressBarActive = false;
                      });
                      final snackBar = SnackBar(
                        content: Text(message),
                        behavior: SnackBarBehavior.floating,
                      );
                      Scaffold.of(context).showSnackBar(snackBar);
                    },
                  ),
                  Center(
                    child: _progressBarActive == true
                        ? const CircularProgressIndicator()
                        : new Container(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            Center(
              child: _SortingStatefulWidget(),
            ),
            _AllCrateStatefulWidget(),
          ].elementAt(_selectedIndex)),
          padding: EdgeInsets.zero,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: dayNightGradient[6].colors[0],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Crate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.transfer_within_a_station),
            label: 'Sorting',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Theme.of(context).backgroundColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _CurrentTasksStatefulWidget extends StatefulWidget {
  _CurrentTasksStatefulWidget({Key key}) : super(key: key);

  @override
  _CurrentTasksStatefulWidgetState createState() =>
      _CurrentTasksStatefulWidgetState();
}

class _CurrentTasksStatefulWidgetState
    extends State<_CurrentTasksStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('CurrentTasks');
  }
}

class _CalendarStatefulWidget extends StatefulWidget {
  _CalendarStatefulWidget({Key key}) : super(key: key);

  @override
  _CalendarStatefulWidgetState createState() => _CalendarStatefulWidgetState();
}

class _CalendarStatefulWidgetState extends State<_CalendarStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Calendar');
  }
}

class _LaterStatefulWidget extends StatefulWidget {
  _LaterStatefulWidget({Key key}) : super(key: key);

  @override
  _LaterStatefulWidgetState createState() => _LaterStatefulWidgetState();
}

class _LaterStatefulWidgetState extends State<_LaterStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Later');
  }
}

class _ProjectsStatefulWidget extends StatefulWidget {
  _ProjectsStatefulWidget({Key key}) : super(key: key);

  @override
  _ProjectsStatefulWidgetState createState() => _ProjectsStatefulWidgetState();
}

class _ProjectsStatefulWidgetState extends State<_ProjectsStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Projects');
  }
}

class _AwaitStatefulWidget extends StatefulWidget {
  _AwaitStatefulWidget({Key key}) : super(key: key);

  @override
  _AwaitStatefulWidgetState createState() => _AwaitStatefulWidgetState();
}

class _AwaitStatefulWidgetState extends State<_AwaitStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Await');
  }
}

class _NotesStatefulWidget extends StatefulWidget {
  _NotesStatefulWidget({Key key}) : super(key: key);

  @override
  _NotesStatefulWidgetState createState() => _NotesStatefulWidgetState();
}

class _NotesStatefulWidgetState extends State<_NotesStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Notes');
  }
}

class _ArchiveStatefulWidget extends StatefulWidget {
  _ArchiveStatefulWidget({Key key}) : super(key: key);

  @override
  _ArchiveStatefulWidgetState createState() => _ArchiveStatefulWidgetState();
}

class _ArchiveStatefulWidgetState extends State<_ArchiveStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Archive');
  }
}

class _IconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;
  final int textSize;

  _IconTextWidget(this.icon, this.text,
      {Key key, this.iconColor, this.textColor, this.textSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: MediaQuery.of(context).size.width * 0.8,
          color: iconColor != null ? iconColor : Theme.of(context).focusColor,
        ),
        Text(text,
            style: TextStyle(
              color:
                  textColor != null ? textColor : Theme.of(context).focusColor,
              fontSize: textSize != null ? textSize : 24,
            ))
      ],
    );
  }
}

class _YesNoStatelessWidget extends StatelessWidget {
  Function yesFunction = () {}, noFunction = () {}, backFunction;
  String question = '', yesText = 'Yes', noText = 'No', backText = 'Back';

  _YesNoStatelessWidget(
      {Key key,
      this.yesFunction,
      this.noFunction,
      this.question,
      this.backFunction,
      this.yesText,
      this.noText,
      this.backText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 32,
        ),
        Text(
          question,
          style: TextStyle(color: Colors.white, fontSize: 42),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 32, top: 32),
                  child: RaisedButton(
                    child: Text(
                      noText != null ? noText : 'No',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    color: Theme.of(context).accentColor,
                    onPressed: noFunction,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                    padding: EdgeInsets.only(left: 32, top: 32),
                    child: RaisedButton(
                      child: Text(
                        yesText != null ? yesText : 'Yes',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: yesFunction,
                    )),
              )
            ],
          ),
        ),
        SizedBox(
          height: 64,
        ),
        backFunction != null
            ? Container(
                width: double.infinity,
                child: RaisedButton(
                  child: Text(
                    backText != null ? backText : 'Back',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).accentColor,
                  onPressed: backFunction,
                ),
              )
            : Container()
      ],
    );
  }
}

class _DatePickerStatefulWidget extends StatefulWidget {
  final String initialText;

  _DatePickerStatefulWidget(this.initialText, {Key key}) : super(key: key);

  @override
  _DatePickerStatefulWidgetState createState() =>
      _DatePickerStatefulWidgetState(initialText);
}

class _DatePickerStatefulWidgetState extends State<_DatePickerStatefulWidget> {
  final String initialText;
  DateTime dateTime;

  _DatePickerStatefulWidgetState(this.initialText);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: Theme.of(context).accentColor,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            initialText +
                (dateTime != null
                    ? (':\n' + userDateFormat.format(dateTime))
                    : ''),
            textAlign: TextAlign.center,
          ),
        ),
        onPressed: () async {
          DateTime d = await showDatePicker(
              context: context,
              initialDate: dateTime == null ? DateTime.now() : dateTime,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365 * 200)));
          if (d != null) {
            setState(() {
              dateTime = d;
            });
          }
        });
  }
}

class _TimePickerStatefulWidget extends StatefulWidget {
  final String initialText;

  _TimePickerStatefulWidget(this.initialText, {Key key}) : super(key: key);

  @override
  _TimePickerStatefulWidgetState createState() =>
      _TimePickerStatefulWidgetState(initialText);
}

class _TimePickerStatefulWidgetState extends State<_TimePickerStatefulWidget> {
  final String initialText;
  TimeOfDay timeOfDay;

  _TimePickerStatefulWidgetState(this.initialText);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: Theme.of(context).accentColor,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            initialText +
                (timeOfDay != null ? (':\n' + timeOfDay.format(context)) : ''),
            textAlign: TextAlign.center,
          ),
        ),
        onPressed: () async {
          TimeOfDay t = await showTimePicker(
              context: context,
              initialTime: timeOfDay == null ? TimeOfDay.now() : timeOfDay);
          if (t != null) {
            setState(() {
              timeOfDay = t;
            });
          }
        });
  }
}

class _SortingStatefulWidget extends StatefulWidget {
  _SortingStatefulWidget({Key key}) : super(key: key);

  @override
  _SortingStatefulWidgetState createState() => _SortingStatefulWidgetState();
}

class _SortingStatefulWidgetState extends State<_SortingStatefulWidget> {
  var _state = 0;
  GlobalKey<_DatePickerStatefulWidgetState> _datePickerKey = GlobalKey();
  List<int> _prevStates = [];
  bool _isFinishing = false;
  Future<CrateRecord> _record;
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
    String url = "/";
    var id = (await _record).id;
    switch(newState) {
      case stateArchiveDone:
        url = url + "archive/make_archive";
        print("ARCHIVE");
        break;
    }
    url = HOST + "/api" + url + "?id=$id";
    print("full url: $url");
    try {
      var resp = await http.patch(url);
      print(resp);
      if (resp.statusCode != 200) {
        print(resp.statusCode);
        throw Exception(resp.body);
      }
    }
    catch (e) {
      _isFinishing = false;
      print("Failed to send! $e");
      return;
    }
    setState(() {
      _prevStates.clear();
      _state = newState;
      _isFinishing = false;
    });
    switch (newState) {
      case stateProjectDone:
        break;
    }

    _fetchRecord();
  }

  @override
  void initState() {
    super.initState();
    _record = fetchLastCrateRecord();
  }

  _fetchRecord() {
    _stateResetter();
  }

  Future<void> _stateResetter() async {
    await sleep1();
    setState(() {
      _record = fetchLastCrateRecord();
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
      builder: (BuildContext context, AsyncSnapshot<CrateRecord> snapshot) {
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
                _YesNoStatelessWidget(
                  question: 'Any to do with this?',
                  yesFunction: () => _setState(stateIsMyTask),
                  noFunction: () => _setState(stateArchiveOrNote),
                ),
                _YesNoStatelessWidget(
                  question: 'Is it my task?',
                  yesFunction: () => _setState(stateIsNow),
                  noFunction: () => _setState(stateAwait),
                ),
                _YesNoStatelessWidget(
                  question: 'Now?',
                  yesFunction: () => _setState(stateIsOneStep),
                  noFunction: () => _setState(stateIsTimed),
                ),
                _YesNoStatelessWidget(
                  question: 'One step?',
                  yesFunction: () => _setState(stateIsEpsilonTime),
                  noFunction: () => _setState(stateProject),
                ),
                _YesNoStatelessWidget(
                  question: 'Can be done in a little of time?',
                  yesFunction: () => _setState(stateDoIt),
                  noFunction: () => _setState(stateCurrentTask),
                ),
                _YesNoStatelessWidget(
                  question: 'Put to archive or notes?',
                  yesText: 'Archive',
                  yesFunction: () => _setState(stateArchive),
                  noText: 'Notes',
                  noFunction: () => _setState(stateNotes),
                ),
                _YesNoStatelessWidget(
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
                        child: _DatePickerStatefulWidget('Execution date')),
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        child: _TimePickerStatefulWidget('Execution time')),
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
                        child: _DatePickerStatefulWidget('Execution date')),
                    const SizedBox(height: 32),
                    Container(
                        width: double.infinity,
                        child: _TimePickerStatefulWidget('Execution time')),
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
                _IconTextWidget(
                    Icons.list_alt, 'Project added to current projects!',
                    iconColor: Colors.white, textColor: Colors.white),
                _IconTextWidget(Icons.done, 'Task done!',
                    iconColor: Colors.white, textColor: Colors.white),
                _IconTextWidget(Icons.timelapse, 'Task added to current tasks!',
                    iconColor: Colors.white, textColor: Colors.white),
                _IconTextWidget(
                    Icons.archive_rounded, 'Record added to archive!',
                    iconColor: Colors.white, textColor: Colors.white),
                _IconTextWidget(Icons.edit, 'Record added to notes!',
                    iconColor: Colors.white, textColor: Colors.white),
                _IconTextWidget(Icons.calendar_today, 'Task added on calendar!',
                    iconColor: Colors.white, textColor: Colors.white),
                _IconTextWidget(Icons.timelapse, 'Task added on later tasks!',
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
          children.add(_IconTextWidget(
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

class _AllCrateStatefulWidget extends StatefulWidget {
  _AllCrateStatefulWidget({Key key}) : super(key: key);

  @override
  _AllCrateStatefulWidgetState createState() => _AllCrateStatefulWidgetState();
}

class _AllCrateStatefulWidgetState extends State<_AllCrateStatefulWidget> {
  ScrollController controller;
  final _allCrateRecords = <CrateRecord>[];
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
      records = await fetchRecords(_allCrateRecords.length, 10);
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
            ? _IconTextWidget(
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

  Widget _buildRow(CrateRecord record) {
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
    var list = (await fetchRecords(_allCrateRecords.length, 1));
    if (list.length == 0) return true;
    var last = list.elementAt(0);
    return last.id == _allCrateRecords[0].id ||
        last.id == _allCrateRecords[_allCrateRecords.length - 1].id;
  }

  Future<bool> hasNewElements() async {
    if (isLoading) return false;
    if (_allCrateRecords.length == 0) return true;
    var first = (await fetchRecords(0, 1)).elementAt(0);
    return first.id != _allCrateRecords[0].id &&
        first.id != _allCrateRecords[_allCrateRecords.length - 1].id;
  }
}

class CrateRecord {
  final int id;
  final String note;
  final DateTime creationDate;

  CrateRecord({this.id, this.note, this.creationDate});

  factory CrateRecord.fromJson(Map<String, dynamic> json) {
    return CrateRecord(
        id: json['id'],
        note: json['note'],
        creationDate: serverDateFormat
            .parse(json['creation_date'])
            .add(DateTime.now().timeZoneOffset));
  }

  Map<String, dynamic> toJson() {
    var dat = serverDateFormat.format(creationDate);
    return jsonDecode('{"id": $id, "note": "$note", "creaton_date": $dat}');
  }
}

Future<CrateRecord> fetchRecord(int id) async {
  final http.Response response = await http.get(
    '$HOST/api/crate/get_record?id=$id',
    headers: <String, String>{
      'Content-Type': 'charset=UTF-8',
    },
  );
  if (response.statusCode == 200)
    return CrateRecord.fromJson(jsonDecode(response.body));
  else
    throw Exception('Failed to load crate record with an id $id');
}

Future<CrateRecord> fetchLastCrateRecord() async {
  return (await fetchRecords(0, 1)).elementAt(0);
}

Future<Set<CrateRecord>> fetchRecords(int offset, int limit) async {
  print('Fetch records limit $limit offset $offset');
  final http.Response response = await http.get(
    '$HOST/api/crate/get_records?offset=$offset&limit=$limit',
    headers: <String, String>{
      'Content-Type': 'charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    Set<CrateRecord> ret = Set<CrateRecord>();
    for (final i in jsonDecode(response.body)) {
      print('Fetching $i');
      ret.add(CrateRecord.fromJson(i));
    }
    return ret;
  } else {
    var rb = response.body;
    throw Exception(
        'Failed to load crate record limit $limit offset $offset: $rb');
  }
}

Future<http.Response> createCrateRecord(String note) async {
  final http.Response response = await http.post(
    '$HOST/api/crate/post_record',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'note': note,
    }),
  );
  return response;
}

double getLightRedViaHour(double hour) {
  final double a = -1.31004,
      b = 94.6404,
      c = -137.295,
      d = 68.0758,
      e = -14.7418,
      f = 1.64884,
      g = -0.0969477,
      h = 0.00256625,
      i = -5.11382 * pow(10, -6),
      j = -7.04052 * pow(10, -7);
  return a +
      b * hour +
      c * pow(hour, 2) +
      d * pow(hour, 3) -
      e * pow(hour, 4) +
      f * pow(hour, 5) +
      g * pow(hour, 6) +
      h * pow(hour, 7) +
      i * pow(hour, 8) +
      j * pow(hour, 9);
}

double getLightGreenViaHour(double hour) {
  final double a = 24.5474,
      b = 27.8814,
      c = -35.7181,
      d = 35.0174,
      e = -11.8376,
      f = 1.99829,
      g = -0.189334,
      h = 0.0102199,
      j = -0.000293351,
      k = 3.47462 * pow(10, -6);
  return a +
      b * hour +
      c * pow(hour, 2) +
      d * pow(hour, 3) -
      e * pow(hour, 4) +
      f * pow(hour, 5) +
      g * pow(hour, 6) +
      h * pow(hour, 7) +
      j * pow(hour, 8) +
      k * pow(hour, 9);
}

double getLightBlueViaHour(double hour) {
  final double a = 44.4208,
      b = -0.163395,
      c = 15.2644,
      d = 10.0952,
      e = -6.38685,
      f = 1.30662,
      g = -0.134333,
      h = 0.00754987,
      j = -0.00022217,
      k = 2.68613 * pow(10, -6);
  return a +
      b * hour +
      c * pow(hour, 2) +
      d * pow(hour, 3) -
      e * pow(hour, 4) +
      f * pow(hour, 5) +
      g * pow(hour, 6) +
      h * pow(hour, 7) +
      j * pow(hour, 8) +
      k * pow(hour, 9);
}

Color getLightColorViaHour(double hour) {
  return dayNightGradient[hour.round()].colors[0];
  // return Color.fromARGB(255, getLightRedViaHour(hour).round(), getLightGreenViaHour(hour).round(), getLightBlueViaHour(hour).round());
  // return Color.fromARGB(255, (dayNightGradient[8].colors[1].red * (hour / 24)).round(), (dayNightGradient[8].colors[1].green * (hour / 24)).round(), (dayNightGradient[8].colors[1].blue * (hour / 24)).round());
}

final Alignment dayNightBegin = Alignment.centerLeft,
    dayNightEnd = Alignment.centerRight;

final List<LinearGradient> dayNightGradient = [
  //0
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 1, 36, 89),
      Color.fromARGB(255, 0, 19, 34),
    ],
    tileMode: TileMode.repeated,
  ),
//1
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 0, 57, 114),
      Color.fromARGB(255, 0, 19, 34),
    ],
    tileMode: TileMode.repeated,
  ),
//2
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 0, 57, 114),
      Color.fromARGB(255, 0, 19, 34),
    ],
    tileMode: TileMode.repeated,
  ),
//3
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 0, 67, 114),
      Color.fromARGB(255, 0, 24, 43),
    ],
    tileMode: TileMode.repeated,
  ),
//4
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 0, 67, 114),
      Color.fromARGB(255, 1, 29, 52),
    ],
    tileMode: TileMode.repeated,
  ),
//5
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 1, 103, 146),
      Color.fromARGB(255, 0, 24, 43),
    ],
    tileMode: TileMode.repeated,
  ),
//6
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 7, 114, 159),
      Color.fromARGB(255, 4, 44, 71),
    ],
    tileMode: TileMode.repeated,
  ),
//7
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 18, 161, 192),
      Color.fromARGB(255, 7, 80, 110),
    ],
    tileMode: TileMode.repeated,
  ),
//8
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 116, 212, 204),
      Color.fromARGB(255, 19, 134, 166),
    ],
    tileMode: TileMode.repeated,
  ),
//9
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 239, 238, 188),
      Color.fromARGB(255, 97, 208, 207),
    ],
    tileMode: TileMode.repeated,
  ),
//10
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 254, 225, 84),
      Color.fromARGB(255, 163, 222, 198),
    ],
    tileMode: TileMode.repeated,
  ),
//11
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 253, 195, 82),
      Color.fromARGB(255, 232, 237, 146),
    ],
    tileMode: TileMode.repeated,
  ),
//12
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 255, 172, 111),
      Color.fromARGB(255, 255, 228, 103),
    ],
    tileMode: TileMode.repeated,
  ),
//13
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 253, 166, 90),
      Color.fromARGB(255, 255, 228, 103),
    ],
    tileMode: TileMode.repeated,
  ),
//14
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 253, 158, 88),
      Color.fromARGB(255, 255, 228, 103),
    ],
    tileMode: TileMode.repeated,
  ),
//15
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 241, 132, 72),
      Color.fromARGB(255, 255, 211, 100),
    ],
    tileMode: TileMode.repeated,
  ),
//16
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 240, 107, 126),
      Color.fromARGB(255, 249, 168, 86),
    ],
    tileMode: TileMode.repeated,
  ),
//17
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 202, 90, 146),
      Color.fromARGB(255, 244, 137, 107),
    ],
    tileMode: TileMode.repeated,
  ),
//18
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 91, 44, 131),
      Color.fromARGB(255, 209, 98, 139),
    ],
    tileMode: TileMode.repeated,
  ),
//19
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 55, 26, 121),
      Color.fromARGB(255, 113, 54, 132),
    ],
    tileMode: TileMode.repeated,
  ),
//20
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 40, 22, 107),
      Color.fromARGB(255, 69, 33, 124),
    ],
    tileMode: TileMode.repeated,
  ),
//21
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 25, 40, 97),
      Color.fromARGB(255, 55, 32, 116),
    ],
    tileMode: TileMode.repeated,
  ),
//22
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 4, 11, 60),
      Color.fromARGB(255, 35, 48, 114),
    ],
    tileMode: TileMode.repeated,
  ),
//23
  LinearGradient(
    begin: dayNightBegin,
    end: dayNightEnd,
    colors: [
      Color.fromARGB(255, 4, 11, 60),
      Color.fromARGB(255, 1, 36, 89),
    ],
    tileMode: TileMode.repeated,
  ),
];

Future sleep1() {
  return Future.delayed(const Duration(seconds: 1), () => "1");
}
