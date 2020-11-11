import 'package:flutter/material.dart';

import 'app.dart' as a;
import 'calendar/calendar.dart' as calendar;
import 'current/current.dart' as current;
import 'later/later.dart' as later;
import 'projects/projects.dart' as projects;
import 'await/await.dart' as wait;
import 'notes/notes.dart' as notes;
import 'archive/archive.dart' as archive;
import 'crate/crate.dart' as crate;
import 'done/done.dart' as done;

final metas = [crate.meta, current.meta, calendar.meta, later.meta, projects.meta, wait.meta, notes.meta, done.meta, archive.meta];

class RootStatefulWidget extends StatefulWidget {
  RootStatefulWidget({Key key}) : super(key: key);

  @override
  _RootStatefulWidgetState createState() => _RootStatefulWidgetState();
}

class _RootStatefulWidgetState extends State<RootStatefulWidget> {
  Widget _mainWidget = metas[0].content;


  @override
  Widget build(BuildContext context) {
    final drawerList = <Widget>[
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
      )
    ];
    for (var i in metas) {
      drawerList.add(
        ListTile(
          leading: Icon(
            i.icon,
            color: Colors.white60,
          ),
          title: Text(
            i.title,
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            setState(() => _mainWidget = i.content);
            Navigator.pop(context);
          },
        )
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(a.title),
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            padding: EdgeInsets.zero,
            children: drawerList
          ),
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        ),
      ),
      body: _mainWidget,
    );
  }
}
