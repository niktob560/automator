import 'package:flutter/material.dart';

import 'package:automator/meta.dart';

final meta =
Meta(Icons.library_books, 'Projects', ProjectsStatefulWidget());

class ProjectsStatefulWidget extends StatefulWidget {
  ProjectsStatefulWidget({Key key}) : super(key: key);

  @override
  ProjectsStatefulWidgetState createState() => ProjectsStatefulWidgetState();
}

class ProjectsStatefulWidgetState extends State<ProjectsStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(meta.title);
  }
}
