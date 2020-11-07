import 'package:flutter/material.dart';

class CurrentTasksStatefulWidget extends StatefulWidget {
  CurrentTasksStatefulWidget({Key key}) : super(key: key);

  @override
  CurrentTasksStatefulWidgetState createState() =>
      CurrentTasksStatefulWidgetState();
}

class CurrentTasksStatefulWidgetState
    extends State<CurrentTasksStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('CurrentTasks');
  }
}