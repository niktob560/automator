import 'package:flutter/material.dart';

class NotesStatefulWidget extends StatefulWidget {
  NotesStatefulWidget({Key key}) : super(key: key);

  @override
  NotesStatefulWidgetState createState() => NotesStatefulWidgetState();
}

class NotesStatefulWidgetState extends State<NotesStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Notes');
  }
}
