import 'package:flutter/material.dart';

import 'package:automator/rest_api/api_service.dart';
import 'package:automator/rest_api/models.dart';
import 'package:automator/endless_list.dart';
import 'package:automator/misc.dart';

import 'package:automator/meta.dart';

final meta = Meta(Icons.accessibility, 'Await', AwaitWidget());

class AwaitWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => EndlessListStatefulWidget<AwaitRecord>(
      (already) => ApiService.getAwaitRecords(limit: 10, offset: already),
      (context, elem) => Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _getTextWidget(elem.note, textSize: 18),
              _getTextWidget('Executor: ${elem.executor}',
                  textSize: 14, color: Colors.white),
              _getTextWidget(
                  'Deadline: ${userDateTimeFormat.format(elem.deadline)}',
                  textSize: 14,
                  color: Colors.white),
              _getTextWidget(userDateTimeFormat.format(elem.creationDate),
                  textSize: 12, color: Colors.white70),
              Divider()
            ],
          )),
      Center(
          child: IconTextWidget(meta.icon, 'There is no await records',
              iconColor: Colors.white, textSize: 48)));

  _getTextWidget(text, {textSize = 12.0, color = Colors.white}) => Padding(
      padding: EdgeInsets.all(4),
      child: Text(
        text,
        style: TextStyle(fontSize: textSize, color: color),
        textAlign: TextAlign.left,
      ));
}
