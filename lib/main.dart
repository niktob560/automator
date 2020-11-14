import 'package:automator/misc.dart';
import 'package:automator/prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

import 'rest_api/api_service.dart';


void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    print(details);
  };
  // because of MissingPluginException in WEB
  // ignore: invalid_use_of_visible_for_testing_member
  // SharedPreferences.setMockInitialValues({});
  runApp(AutomatorApp());
}
