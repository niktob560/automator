import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart';

import 'models.dart';

class URLS {
  static const String BASE_URL = kReleaseMode? 'https://gtd-nobodyhomie.ddns.net/api' : 'http://192.168.1.66:8000/api';
}

class ApiService {
  static Future<String> _expiringToken;
  static String _longToken;

  static Future<bool> login(String token) async {
    final response = await http.post('${URLS.BASE_URL}/security/login',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'token': token,
      })
    );
    if (response.statusCode != 200) {
      print('Failed to login: bad connection');
      return null;
    }
    var body = json.decode(response.body);
    if (body['code'] != 0) {
      print('Failed to login: bad token');
      return false;
    }
    print('Connected, $body');
    print('Connected, ${response.body}');
    _longToken = token;
    _expiringToken = (() async { return '${body['token']}';}());
    return true;
  }

  static Future<bool> sendPost(url, bodyJson, {relogin = false}) async {
    print('Making ${URLS.BASE_URL}$url $bodyJson ${await _expiringToken}');
    final response = await http.post('${URLS.BASE_URL}$url',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await _expiringToken}'
        },
        body: bodyJson
    );
    if (response.statusCode == 200 || response.statusCode == 401) {
      var body = json.decode(response.body);
      if (response.statusCode == 401 || body['detail'] == 'Unauthorized') {
        print('Relogin ${response.body}');
        if (!relogin && await login(await _longToken)) {
          print('Relogin successed');
          return sendPost(url, bodyJson, relogin: true);
        }
        else {
          print('Relogin unsuccessed ${response.body}');
          return null;
        }
      }
      else {
        return body['code'] == 0;
      }
    }
    else {
      print('${response.statusCode}');
      return null;
    }
  }

  static Future<bool> postCrate(String note) async {
    return sendPost('/crate/post_record', jsonEncode(<String, String> { 'note': note }));
  }

  static Future<bool> makeArchive(int id) async {
    return sendPost('/archive/make_archive', jsonEncode(<String, String> { 'id': '$id' }));
  }

  static get expiringToken => _expiringToken;
  static get longToken => _longToken;
}