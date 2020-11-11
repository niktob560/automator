import 'package:flutter/material.dart';

import 'package:automator/endless_list.dart';
import 'package:automator/rest_api/models.dart';
import 'package:automator/rest_api/api_service.dart';

import 'package:automator/misc.dart';

import 'package:automator/meta.dart';

final meta = Meta(Icons.timelapse, 'Current tasks', CurrentWidget());

class CurrentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => EndlessListStatefulWidget<Record>(
      (already) => ApiService.getCurrentRecords(limit: 10, offset: already),
      (context, elem) => _buildRow(elem),
      Center(
          child: IconTextWidget(meta.icon, 'There is no current tasks',
              iconColor: Colors.white, textSize: 48)));

  Widget _buildRow(Record record) => Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ListTile(
            title: Text(
              record.note,
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            subtitle: Text(
              userDateTimeFormat.format(record.creationDate),
              style: TextStyle(fontSize: 12.0, color: Colors.white70),
            ),
            onTap: () {
              //TODO: open details
            },
          ),
          Divider(),
        ],
      ));
}
