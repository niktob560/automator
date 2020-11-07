import 'package:flutter/material.dart';

class AwaitStatefulWidget extends StatefulWidget {
  AwaitStatefulWidget({Key key}) : super(key: key);

  @override
  AwaitStatefulWidgetState createState() => AwaitStatefulWidgetState();
}

class AwaitStatefulWidgetState extends State<AwaitStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Await');
  }
}
