import 'package:flutter/material.dart';
import 'package:morpheus/morpheus.dart';

import 'day_night_gradients.dart';

import 'app.dart' as a;
import 'calendar/calendar.dart' as calendar;
import 'current/current.dart' as current;
import 'later/later.dart' as later;
import 'projects/projects.dart' as projects;
import 'await/await.dart' as wait;
import 'notes/notes.dart' as notes;
import 'archive/archive.dart' as archive;
import 'crate/crate.dart' as crate;


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
        title: const Text(a.title),
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
                  a.title,
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
                    mainWidget = current.CurrentTasksStatefulWidget();
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
                    mainWidget = calendar.CalendarStatefulWidget();
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
                    mainWidget = later.LaterStatefulWidget();
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
                    mainWidget = projects.ProjectsStatefulWidget();
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
                    mainWidget = wait.AwaitStatefulWidget();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  notes.icon,
                  color: Colors.white60,
                ),
                title: Text(
                  notes.title,
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    mainWidget = notes.NotesWidget();
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
                    mainWidget = archive.ArchiveStatefulWidget();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: MorpheusTabView(
        child: Padding(
          child: Center(
              child: [
            crate.CrateAddStatefulWidget(),
            crate.SortingStatefulWidget(),
            crate.AllCrateStatefulWidget(),
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
