import 'package:flutter/material.dart';

class ProjectsStatefulWidget extends StatefulWidget {
  ProjectsStatefulWidget({Key key}) : super(key: key);

  @override
  ProjectsStatefulWidgetState createState() => ProjectsStatefulWidgetState();
}

class ProjectsStatefulWidgetState extends State<ProjectsStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Text('Projects');
  }
}
