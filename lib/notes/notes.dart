import 'package:flutter/material.dart';

import 'package:automator/rest_api/api_service.dart';
import 'package:automator/rest_api/models.dart';
import 'package:automator/endless_list.dart';
import 'package:automator/misc.dart';

import 'package:automator/meta.dart';

final meta = Meta(
    Icons.edit,
    'Notes',
    NotesWidget());


class NotesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => EndlessListStatefulWidget<Record>(
      (already) => ApiService.getNotesRecords(limit: 10, offset: already),
      (context, elem) => Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ListTile(
                title: Text(
                  elem.note,
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
                subtitle: Text(
                  userDateTimeFormat.format(elem.creationDate),
                  style: TextStyle(fontSize: 12.0, color: Colors.white70),
                ),
                onTap: () {
                  //TODO: open details
                },
              ),
              Divider(),
            ],
          )),
      Center(
          child: IconTextWidget(meta.icon, 'There is no note records',
              iconColor: Colors.white, textSize: 48)));
}
