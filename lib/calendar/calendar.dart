import 'package:flutter/material.dart';

class CalendarStatefulWidget extends StatefulWidget {
  CalendarStatefulWidget({Key key}) : super(key: key);

  @override
  CalendarStatefulWidgetState createState() => CalendarStatefulWidgetState();
}

class CalendarStatefulWidgetState extends State<CalendarStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Calendar');
  }
}
