import 'dart:async';

import 'package:automator/configurer.dart';
import 'package:automator/rest_api/api_service.dart';
import 'package:flutter/material.dart';

import 'app.dart' as a;
import 'calendar/calendar.dart' as calendar;
import 'current/current.dart' as current;
import 'later/later.dart' as later;
import 'misc.dart';
import 'projects/projects.dart' as projects;
import 'await/await.dart' as wait;
import 'notes/notes.dart' as notes;
import 'archive/archive.dart' as archive;
import 'crate/crate.dart' as crate;
import 'done/done.dart' as done;

import 'package:automator/prefs.dart';

final metas = [
  crate.meta,
  current.meta,
  calendar.meta,
  later.meta,
  projects.meta,
  wait.meta,
  notes.meta,
  done.meta,
  archive.meta
];

class RootStatefulWidget extends StatefulWidget {
  RootStatefulWidget({Key key}) : super(key: key);

  @override
  _RootStatefulWidgetState createState() => _RootStatefulWidgetState();
}

class _RootStatefulWidgetState extends State<RootStatefulWidget> {
  Widget _mainWidget = metas[0].content;
  bool _isAuthed;
  StreamSubscription<bool> _authSub;

  @override
  Widget build(BuildContext context) {
    if (_isAuthed == null) {
      print('Running init');
      () async {
        var a = await PreferenceManager.isAuthed();
        setState(() {
          _isAuthed = a;
        });
        _authSub = PreferenceManager.authStream.listen((value) {
          if (_isAuthed != value)
            setState(() {
              _isAuthed = value;
            });
          if (value) _authSub.cancel();
        });
      }();
    }
    return _isAuthed != null
        ? _getContent(_isAuthed)
        : const Center(child: const CircularProgressIndicator());
    // return FutureBuilder(
    //     future: PreferenceManager.isAuthed(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done &&
    //           snapshot.data != null)
    //         return _getContent(snapshot.data);
    //       else
    //         return const Center(
    //           child: CircularProgressIndicator(),
    //         );
    //     });
  }

  _getContent(configured) {
    print('getContent $configured');
    if (configured) {
      // ApiService.login(
      //     'vPtGkVWfRXfNXyRCmUJtXZkS5CTEfaOjOruVxevqvXGybc1CKi9M9WEwL3LFbecyBRT4gSJrQXUJrKKUxmDpCKI2ntzu3DEjxxwSYYJPmAHqk9ZKLuZ17U1sKKnLdevZdo8JH8VML4IAST9fNEMYHm5wv6hlZj6CLdRQTT1Tx2NLBNFwQfPceyUbpPe587G15n6F4xh6snfvwhRKwPbzsPnW4iKeLPji4ZyYD3Kbd3EhG9UymRCaoUUiRO4q6OENNxg428ZhhaEsDFb9FIqVIGP5B9OVMNhsj9Ds59vQDOR9DTAzoZNhICUGGSMTab8yAC6O8cJQEe1u9lxXqMmSJTW1ZKFm3LVMX8Vs5UUfbSXrrMkBtJnEFQiuZFU1L9bp1q8EalvsXEl8JgSMv27Oy7P19MQsAUC5qikRv7QDLhfTbD77L3aygEktvjfBch268jJbCnoRKCCDTnL4qc4xuNhs2Sb7S3AFs9TijwlFJl7fpWmaBtdeDSY42UsKcj66cp6E1ReyMP4O9SXDVWFv6QnKy8kvAz4tSi7ygsM2wbFz8wjKgTxiNSxjTxrIhS3xsfAFCQHiO6Etdde4hEiCQEot5f8sJu9TuPl797JmlyheCBY2fdqmpbOYHvLUM4QrqOtUa7V2ROWXiIRSExVt7qxQLpTjdUy35qxm22Ff3Va4moGH3SA2Snxs8wjMvt2wd1iWm1UXUg2fqMwYRaANuWZjtyNijn4UdqGxzTQaVREQy8f4hN9sGzG12XJdGAKr1y3tsTtxUAZMklfe4Gic1g2D9jXbhbDDq1f4voZVvBooxFefQ8ZnvR5LKznyw3SvRwnFQR6CqvGBxyYnJY7dMXys2nA7GhaPNvyBVNspgT5yX6UQwGr7cw83hCE4NVGL2g9qUZFvVyINH9U7yUOyUv677PBbcey8Fa6jDdUYOjTxK1uoSsU2Bf5d1PgcPcQCSrtdqbCun3xKmFDsZ94p5cGQxm8TozPvjPXXmdyvMGFsm1pTpbhXE9Ot8vfdRXOp');
      return _getConfiguredContent();
    } else
      return ConfigurerWidget();
  }

  _getConfiguredContent() {
    ApiService.login(PreferenceManager.token);
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
      drawerList.add(ListTile(
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
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(a.title),
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(padding: EdgeInsets.zero, children: drawerList),
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
        ),
      ),
      body: _mainWidget,
    );
  }
}
