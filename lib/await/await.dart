import 'package:flutter/material.dart';

import 'package:automator/meta.dart';

final meta =
Meta(Icons.accessibility, 'Await', AwaitStatefulWidget());

class AwaitStatefulWidget extends StatefulWidget {
  AwaitStatefulWidget({Key key}) : super(key: key);

  @override
  AwaitStatefulWidgetState createState() => AwaitStatefulWidgetState();
}

class AwaitStatefulWidgetState extends State<AwaitStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(meta.title);
  }
}
