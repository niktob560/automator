import 'package:flutter/material.dart';

import 'package:automator/meta.dart';

final meta = Meta(Icons.done_all, 'Done', DoneWidget());

class DoneWidget extends StatefulWidget {
  DoneWidget({Key key}) : super(key: key);

  @override
  DoneWidgetState createState() => DoneWidgetState();
}

class DoneWidgetState extends State<DoneWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(meta.title);
  }
}
