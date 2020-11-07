import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_encoder/url_encoder.dart';

import 'package:flutter/foundation.dart';


import 'models.dart';

class URLS {
  static const String BASE_URL = kReleaseMode? 'https://gtd-nobodyhomie.ddns.net/api' : 'http://192.168.1.66:8000/api',
                      CRATE = '/crate',
                      ARCHIVE = '/archive',
                      POST_RECORD = '/post_record',
                      GET_RECORDS = '/get_records',
                      MAKE_ARCHIVE = '/make_archive';
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

  static Future<dynamic> sendPost(url, bodyJson, {relogin = false}) async {
    print('POST ${URLS.BASE_URL}$url $bodyJson ${await _expiringToken}');
    final response = await http.post('${URLS.BASE_URL}$url',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await _expiringToken}'
        },
        body: bodyJson
    );
    if (response.statusCode == 200 || response.statusCode == 401) {
      var body = json.decode(response.body);
      if (response.statusCode == 401) {
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
        return body;
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
      String q = "";
      for (var i in args.entries) {
        q = '${i.key}=${i.value}&$q';
      }
      q = urlEncode(text: q);
      uri = '$uri?$q';
      print('uri: $uri');
      final response = await http.get('$uri',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await _expiringToken}'
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
    var b = await sendPost('${URLS.ARCHIVE}${URLS.MAKE_ARCHIVE}', jsonEncode(<String, String> { 'id': '$id' }));
    return b['code'] == 0;
  }

  static Future<Set<CrateRecord>> getCrateRecords({limit=100, offset=0}) async {
    var b = await sendGet('${URLS.CRATE}${URLS.GET_RECORDS}', <String, String> {'limit': '$limit', 'offset': '$offset'});
    print('getCrateRecords $b');
    Set<CrateRecord> ret = Set();
    for (var i in b) {
      ret.add(CrateRecord.fromJson(i));
    }
    return ret;
  }

  static Future<CrateRecord> getLastCrateRecords() async {
    var b = (await sendGet('${URLS.CRATE}${URLS.GET_RECORDS}', <String, String> {'limit': '1', 'offset': '0'}));
    print('getLastCrateRecords $b');
    return CrateRecord.fromJson(b[0]);
  }

  static get expiringToken => _expiringToken;
  static get longToken => _longToken;
}