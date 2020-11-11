import 'package:flutter/material.dart';

import 'package:automator/meta.dart';

final meta = Meta(Icons.archive, 'Archive', ArchiveStatefulWidget());

class ArchiveStatefulWidget extends StatefulWidget {
  ArchiveStatefulWidget({Key key}) : super(key: key);

  @override
  ArchiveStatefulWidgetState createState() => ArchiveStatefulWidgetState();
}

class ArchiveStatefulWidgetState extends State<ArchiveStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(meta.title);
  }
}
