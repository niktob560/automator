import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'day_night_gradients.dart';

final DateFormat serverDateFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ"),
    userDateTimeFormat = DateFormat("dd.MM.yyyy HH:mm"),
    userDateFormat = DateFormat("dd.MM.yyyy");

formatDateTimeForServer(DateTime dt) {
  return '${dt.year}-${dt.month}-${dt.day}T${dt.hour}:${dt.minute}:${dt.second}Z';
}

double getMaxIconSize(context) {
  final maxSize = max(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
      minSize = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
  return minSize * min(minSize / maxSize, 0.8);
}

class IconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;
  final int textSize;

  IconTextWidget(this.icon, this.text,
      {Key key, this.iconColor, this.textColor, this.textSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: getMaxIconSize(context),
          color: iconColor != null ? iconColor : Theme.of(context).focusColor,
        ),
        Text(text,
            style: TextStyle(
              color: textColor != null ? textColor : Colors.white,
              fontSize: (textSize != null ? textSize : 24) * 1.0,
            ),
        textAlign: TextAlign.center)
      ],
    );
  }
}

class YesNoStatelessWidget extends StatelessWidget {
  Function yesFunction = () {}, noFunction = () {}, backFunction;
  String question = '', yesText = 'Yes', noText = 'No', backText = 'Back';

  YesNoStatelessWidget(
      {Key key,
      this.yesFunction,
      this.noFunction,
      this.question,
      this.backFunction,
      this.yesText,
      this.noText,
      this.backText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 32,
        ),
        Text(
          question,
          style: TextStyle(color: Colors.white, fontSize: 42),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 32, top: 32),
                  child: RaisedButton(
                    child: Text(
                      noText != null ? noText : 'No',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    color: Theme.of(context).accentColor,
                    onPressed: noFunction,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                    padding: EdgeInsets.only(left: 32, top: 32),
                    child: RaisedButton(
                      child: Text(
                        yesText != null ? yesText : 'Yes',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: yesFunction,
                    )),
              )
            ],
          ),
        ),
        SizedBox(
          height: 64,
        ),
        backFunction != null
            ? Container(
                width: double.infinity,
                child: RaisedButton(
                  child: Text(
                    backText != null ? backText : 'Back',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Theme.of(context).accentColor,
                  onPressed: backFunction,
                ),
              )
            : Container()
      ],
    );
  }
}

class DatePickerStatefulWidget extends StatefulWidget {
  final String initialText;
  final Function dateCallback;

  DatePickerStatefulWidget(this.initialText, {Key key, this.dateCallback})
      : super(key: key);

  @override
  DatePickerStatefulWidgetState createState() =>
      DatePickerStatefulWidgetState(initialText, dateCallback);
}

class DatePickerStatefulWidgetState extends State<DatePickerStatefulWidget> {
  final String initialText;
  DateTime _dateTime;
  final Function dateCallback;

  DatePickerStatefulWidgetState(this.initialText, this.dateCallback);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: Theme.of(context).accentColor,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            initialText +
                (_dateTime != null
                    ? (':\n' + userDateFormat.format(_dateTime))
                    : ''),
            textAlign: TextAlign.center,
          ),
        ),
        onPressed: () async {
          DateTime d = await showDatePicker(
              context: context,
              initialDate: _dateTime == null ? DateTime.now() : _dateTime,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365 * 200)));
          if (d != null) {
            setState(() {
              _dateTime = d;
            });
            if (dateCallback != null) dateCallback(d);
          }
        });
  }
}

class TimePickerStatefulWidget extends StatefulWidget {
  final String initialText;
  final Function timeCallback;

  TimePickerStatefulWidget(this.initialText, {Key key, this.timeCallback})
      : super(key: key);

  @override
  TimePickerStatefulWidgetState createState() =>
      TimePickerStatefulWidgetState(initialText, timeCallback);
}

class TimePickerStatefulWidgetState extends State<TimePickerStatefulWidget> {
  final String initialText;
  TimeOfDay timeOfDay;
  final Function timeCallback;

  TimePickerStatefulWidgetState(this.initialText, this.timeCallback);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        color: Theme.of(context).accentColor,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            initialText +
                (timeOfDay != null ? (':\n' + timeOfDay.format(context)) : ''),
            textAlign: TextAlign.center,
          ),
        ),
        onPressed: () async {
          TimeOfDay t = await showTimePicker(
              context: context,
              initialTime: timeOfDay == null ? TimeOfDay.now() : timeOfDay);
          if (t != null) {
            setState(() {
              timeOfDay = t;
            });
            if (timeCallback != null) timeCallback(t);
          }
        });
  }
}

Future sleep1() {
  return Future.delayed(const Duration(seconds: 1), () => "1");
}

final TimeOfDayFormat userTimeFormat = TimeOfDayFormat.HH_colon_mm;

InputDecoration getInputDecoration(String labelText, String errorText) {
  return InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
          color: dayNightGradient[7].colors[0], style: BorderStyle.solid),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
          color: dayNightGradient[7].colors[0], style: BorderStyle.solid),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(
          color: dayNightGradient[7].colors[0], style: BorderStyle.solid),
    ),
    labelText: labelText,
    errorText: errorText,
    hintStyle: TextStyle(color: Colors.white60),
    labelStyle: TextStyle(color: dayNightGradient[7].colors[0]),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5.0),
      borderSide: BorderSide(color: Colors.white),
    ),
  );
}
