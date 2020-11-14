import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

Future<void> init() async {}

class PreferenceManager {
  static const TOKEN_KEY = 'token', HOST_KEY = 'host';
  static final StreamController<bool> _authStreamController =
      StreamController<bool>.broadcast();
  static final Stream _authStream = _authStreamController.stream;

  static SharedPreferences _sp;

  static Stream get authStream => _authStream;
  // static String token, host;

  static set host(host) {
    _sp.setString(HOST_KEY, host);
  }

  static set token(token) {
    _sp.setString(TOKEN_KEY, token);
  }

  static get host => _sp.getString(HOST_KEY);
  static get token => _sp.getString(TOKEN_KEY);

  static auth(_host, _token) async {
    if(_sp == null)
      _sp = await SharedPreferences.getInstance();

    host = _host;
    token = _token;

    try {
      _authStreamController.add(true);
    } catch (e) {
      print('$e');
    }
  }

  static Future<bool> isAuthed() async {
    if(_sp == null)
      _sp = await SharedPreferences.getInstance();
    final ret = await () async {
      try {
        print('isAuthed');
        final ret = _sp.containsKey(TOKEN_KEY);
        print('isAuthed $ret');
        return ret != null ? ret : false;
      } catch (e) {
        print('isAuthed error $e');
        return false;
      }
    }();
    try {
      _authStreamController.add(ret);
    } catch (e) {
      print('$e');
    }
    return ret;
  }
}
