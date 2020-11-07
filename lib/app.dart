import 'package:flutter/material.dart';
import 'day_night_gradients.dart';

import 'root.dart';

/// This is the main application widget.
const String title = 'Automat';

class AutomatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData td = ThemeData.dark().copyWith(
        accentColor: dayNightGradient[7].colors[0],
        primaryColor: dayNightGradient[6].colors[0],
        backgroundColor: dayNightGradient[1].colors[1],
        dialogBackgroundColor: dayNightGradient[0].colors[1],
        scaffoldBackgroundColor: dayNightGradient[1].colors[1],
        buttonColor: dayNightGradient[7].colors[0],
        secondaryHeaderColor: dayNightGradient[6].colors[0],
        splashColor: dayNightGradient[0].colors[1],
        cardColor: dayNightGradient[0].colors[0],
        highlightColor: dayNightGradient[6].colors[0],
        buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: dayNightGradient[7].colors[0],
            textTheme: ButtonTextTheme.primary));
    return MaterialApp(
        title: title,
        color: Colors.black,
        home: RootStatefulWidget(),
        theme: td);
  }
}