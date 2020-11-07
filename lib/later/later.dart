import 'package:flutter/material.dart';

class LaterStatefulWidget extends StatefulWidget {
  LaterStatefulWidget({Key key}) : super(key: key);

  @override
  LaterStatefulWidgetState createState() => LaterStatefulWidgetState();
}

class LaterStatefulWidgetState extends State<LaterStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Later');
  }
}