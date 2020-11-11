import 'package:flutter/material.dart';
import 'package:automator/misc.dart';
import 'package:automator/rest_api/api_service.dart';
import 'package:automator/rest_api/models.dart';
import 'package:automator/day_night_gradients.dart';

import 'package:automator/endless_list.dart';

import 'crate.dart';

//TODO: stateless
class AllCrateStatefulWidget extends StatefulWidget {
  AllCrateStatefulWidget({Key key}) : super(key: key);

  @override
  AllCrateStatefulWidgetState createState() => AllCrateStatefulWidgetState();
}

class AllCrateStatefulWidgetState extends State<AllCrateStatefulWidget> {
  Widget new_build(BuildContext context) {
    return EndlessListStatefulWidget<Record>(
        (already) => ApiService.getCrateRecords(offset: already, limit: 10),
        (context, elem) => _buildRow(elem),
        Center(
            child: IconTextWidget(meta.icon, 'There is no crate records',
                iconColor: Colors.white, textSize: 48)));
  }

  @override
  Widget build(BuildContext context) => new_build(context);

  Widget _buildRow(Record record) {
    final int hour = record.creationDate.hour % 24;
    final bool isDay = hour > 10 && hour < 16;
    return Container(
        decoration: BoxDecoration(gradient: dayNightGradient[hour]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ListTile(
              title: Text(
                record.note,
                style: TextStyle(
                    fontSize: 18.0, color: isDay ? Colors.white : Colors.white),
              ),
              subtitle: Text(
                userDateTimeFormat.format(record.creationDate),
                style: TextStyle(
                    fontSize: 12.0,
                    color: isDay ? Colors.white70 : Colors.white70),
              ),
              onTap: () {
                //TODO: open details
              },
            ),
            Divider(),
          ],
        ));
  }
}
