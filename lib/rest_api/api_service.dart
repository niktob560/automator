import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_encoder/url_encoder.dart';

import 'package:flutter/foundation.dart';


import 'models.dart';

class URLS {
  static const String BASE_URL = kReleaseMode? 'https://gtd-nobodyhomie.ddns.net/api' : 'http://192.168.1.66:1234/api',
                      CRATE = '/crate',
                      ARCHIVE = '/archive',
                      NOTES = '/notes',
                      DONE = '/done',
                      CURRENT = '/current',
                      LATER = '/later',
                      POST_RECORD = '/post_record',
                      GET_RECORDS = '/get_records',
                      MAKE_ARCHIVE = '/make_archive',
                      MAKE_NOTE = '/make_note',
                      MAKE_DONE = '/make_done',
                      MAKE_CURRENT = '/make_current',
                      MAKE_LATER = '/make_later';
}

class ApiService {
  static Future<String> _expiringToken;
  static String _longToken;

  static String urlQueryEncode(Map <String, String> queryParams) {
    String q = "";
    if (queryParams != null) {
      for (var i in queryParams.entries) {
        q = '${i.key}=${i.value}&$q';
      }
      q = urlEncode(text: q);
    }
    return q;
  }

  static Future<bool> login(String token) async {
    final response = await http.post('${URLS.BASE_URL}/security/login',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Access-Control-Allow-Origin': '*'
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

  static Future<dynamic> sendPost(url, bodyJson, {relogin = false, Map <String, String> queryParams}) async {
    print('POST ${URLS.BASE_URL}$url $bodyJson $queryParams ${await _expiringToken}');
    final response = await http.post('${URLS.BASE_URL}$url?${urlQueryEncode(queryParams)}',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await _expiringToken}',
          'Access-Control-Allow-Origin': '*'
        },
        body: bodyJson
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    else if (response.statusCode == 401) {
      print('Relogin ${response.body}');
      if (!relogin && await login(await _longToken)) {
        print('Relogin successed');
        return sendPost(url, bodyJson, relogin: true, queryParams: queryParams);
      }
      else {
        print('Relogin unsuccessed ${response.body}');
        return null;
      }
    }
    else {
      print('${response.statusCode}');
      return null;
    }
  }

  static Future<dynamic> sendPatch(url, bodyJson, {relogin = false, Map <String, String> queryParams}) async {
    print('PATCH ${URLS.BASE_URL}$url $bodyJson $queryParams ${await _expiringToken}');
    final uri = '${URLS.BASE_URL}$url?${urlQueryEncode(queryParams)}';
    print(uri);
    final response = await http.patch(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await _expiringToken}',
          'Access-Control-Allow-Origin': '*'
        },
        body: bodyJson
    );
    print('${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    else if (response.statusCode == 401) {
      print('Relogin ${response.body}');
      if (!relogin && await login(await _longToken)) {
        print('Relogin successed');
        return sendPatch(url, bodyJson, relogin: true, queryParams: queryParams);
      }
      else {
        print('Relogin unsuccessed ${response.body}');
        return null;
      }
    }
    else {
      print('${response.statusCode}');
      return null;
    }
  }

  static Future<dynamic> sendGet(String url, Map<String, String> args, {relogin = false}) async {
    print('GET ${URLS.BASE_URL}$url $args ${await _expiringToken}');
    try {
      var uri = '${URLS.BASE_URL}$url';
      uri = '$uri?${urlQueryEncode(args)}';
      print('uri: $uri');
      final response = await http.get('$uri',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await _expiringToken}',
          'Access-Control-Allow-Origin': '*'
        },
      );
      print('${response.statusCode} ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 401) {
        var body = json.decode(response.body);
        if (response.statusCode == 401) {
          print('Relogin ${response.body}');
          if (!relogin && await login(await _longToken)) {
            print('Relogin successed');
            return sendGet(url, args, relogin: true);
          }
          else {
            print('Relogin unsuccessed ${response.body}');
            return null;
          }
        }
        else {
          return body;
        }
      }
      else {
        print('${response.statusCode}');
        return null;
      }
    }
    catch (e) {
      print('$e');
      return null;
    }
  }

  static Future<bool> postCrate(String note) async {
    var b = await sendPost('${URLS.CRATE}${URLS.POST_RECORD}', jsonEncode(<String, String> { 'note': note }));
    print('$b');
    return b['code'] == 0;
  }

  static Future<bool> makeArchive(int id) async {
    var b = await sendPatch('${URLS.ARCHIVE}${URLS.MAKE_ARCHIVE}', null, queryParams: <String, String> { 'id': '$id' });
    return b != null? b['code'] == 0 : null;
  }

  static Future<Set<Record>> getCrateRecords({limit=100, offset=0}) async {
    var b = await sendGet('${URLS.CRATE}${URLS.GET_RECORDS}', <String, String> {'limit': '$limit', 'offset': '$offset'});
    print('getCrateRecords $b');
    Set<Record> ret = Set();
    for (var i in b) {
      ret.add(Record.fromJson(i));
    }
    return ret;
  }

  static Future<Record> getLastCrateRecords() async {
    var b = (await sendGet('${URLS.CRATE}${URLS.GET_RECORDS}', <String, String> {'limit': '1', 'offset': '0'}));
    print('getLastCrateRecords $b');
    return Record.fromJson(b[0]);
  }
  
  static Future<bool> makeNote(int id) async {
    var b = await sendPatch('${URLS.NOTES}${URLS.MAKE_NOTE}', jsonEncode(<String, String> { 'id': '$id' }));
    return b != null? b['code'] == 0 : null;
  }

  static get expiringToken => _expiringToken;
  static get longToken => _longToken;
}