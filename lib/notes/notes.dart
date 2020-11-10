import 'package:flutter/material.dart';

import 'package:automator/rest_api/api_service.dart';
import 'package:automator/rest_api/models.dart';
import 'package:automator/endless_list.dart';
import 'package:automator/misc.dart';

const title = 'Notes';
const icon = Icons.edit;

class NotesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => EndlessListStatefulWidget<Record>(
      (already) => ApiService.getNotesRecords(limit: 10, offset: already),
      (context, elem) => _buildRow(elem));

  Widget _buildRow(Record record) {
    final int hour = record.creationDate.hour % 24;
    final bool isDay = hour > 10 && hour < 16;
    return Container(
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
                fontSize: 12.0, color: isDay ? Colors.white70 : Colors.white70),
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
