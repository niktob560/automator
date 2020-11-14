import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:url_encoder/url_encoder.dart';

import 'package:automator/prefs.dart';

import 'models.dart';

import 'package:automator/misc.dart' as misc;

class URLS {
  static String baseUrl = PreferenceManager.host;
  static const String CRATE = '/crate',
      ARCHIVE = '/archive',
      NOTES = '/notes',
      DONE = '/done',
      CURRENT = '/current',
      LATER = '/later',
      AWAIT = '/await',
      PROJECTS = '/projects',
      CALENDAR = '/calendar',
      POST_RECORD = '/post_record',
      GET_RECORDS = '/get_records',
      MAKE_ARCHIVE = '/make_archive',
      MAKE_NOTE = '/make_note',
      MAKE_DONE = '/make_done',
      MAKE_CURRENT = '/make_current',
      MAKE_LATER = '/make_later',
      MAKE_AWAIT = '/make_await',
      MAKE_PROJECT = '/make_project',
      MAKE_CALENDAR = '/make_calendar';
}

class ApiService {
  static Future<String> _expiringToken;
  static String _longToken = PreferenceManager.token;

  static String urlQueryEncode(Map<String, String> queryParams) {
    String q = "";
    if (queryParams != null) {
      for (var i in queryParams.entries) {
        q = '${i.key}=${i.value}&$q';
      }
      q = urlEncode(text: q);
    }
    return q;
  }

  static Future<bool> login(String token, [String host]) async {
    if (host == null) {
      print('Login host null, set to ${URLS.baseUrl}');
      host = URLS.baseUrl;
    }
    final response = await http.post('$host/security/login',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Access-Control-Allow-Origin': '*'
        },
        body: jsonEncode(<String, String>{
          'token': token,
        }));
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
    final testResponse =
        await http.get('$host/security/test', headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Access-Control-Allow-Origin': '*',
      'Authorization': 'Bearer ${body['token']}'
    });
    print('${testResponse.body}');
    if (testResponse.statusCode == 200) {
      _longToken = token;
      URLS.baseUrl = host;
      _expiringToken = (() async {
        return '${body['token']}';
      }());
      return true;
    } else
      return false;
  }

  static Future<dynamic> sendPost(url, bodyJson,
      {relogin = false, Map<String, String> queryParams}) async {
    print(
        'POST ${URLS.baseUrl}$url $bodyJson $queryParams ${await _expiringToken}');
    final response =
        await http.post('${URLS.baseUrl}$url?${urlQueryEncode(queryParams)}',
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer ${await _expiringToken}',
              'Access-Control-Allow-Origin': '*'
            },
            body: bodyJson);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      print('Relogin ${response.body}');
      if (!relogin && await login(await _longToken)) {
        print('Relogin successed');
        return sendPost(url, bodyJson, relogin: true, queryParams: queryParams);
      } else {
        print('Relogin unsuccessed ${response.body}');
        return null;
      }
    } else {
      print('${response.statusCode}');
      return null;
    }
  }

  static Future<dynamic> sendPatch(url, bodyJson,
      {relogin = false, Map<String, dynamic> queryParams}) async {
    print(
        'PATCH ${URLS.baseUrl}$url $bodyJson $queryParams ${await _expiringToken}');
    final uri = '${URLS.baseUrl}$url?${urlQueryEncode(queryParams)}';
    print(uri);
    final response = await http.patch(uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${await _expiringToken}',
          'Access-Control-Allow-Origin': '*'
        },
        body: bodyJson);
    print('${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      print('Relogin ${response.body}');
      if (!relogin && await login(await _longToken)) {
        print('Relogin successed');
        return sendPatch(url, bodyJson,
            relogin: true, queryParams: queryParams);
      } else {
        print('Relogin unsuccessed ${response.body}');
        return null;
      }
    } else {
      print('${response.statusCode}');
      return null;
    }
  }

  static Future<dynamic> sendGet(String url, Map<String, String> args,
      {relogin = false}) async {
    print('GET ${URLS.baseUrl}$url $args ${await _expiringToken}');
    try {
      var uri = '${URLS.baseUrl}$url';
      uri = '$uri?${urlQueryEncode(args)}';
      print('uri: $uri');
      final response = await http.get(
        '$uri',
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
          } else {
            print('Relogin unsuccessed ${response.body}');
            return null;
          }
        } else {
          return body;
        }
      } else {
        print('${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('$e');
      return null;
    }
  }

  static Future<bool> postCrate(String note) async {
    var b = await sendPost('${URLS.CRATE}${URLS.POST_RECORD}',
        jsonEncode(<String, String>{'note': note}));
    print('$b');
    return b['code'] == 0;
  }

  static Future<bool> makeArchive(int id, {String newNote}) async {
    var b = await sendPatch('${URLS.ARCHIVE}${URLS.MAKE_ARCHIVE}',
        newNote == null ? null : jsonEncode(<String, String>{'note': newNote}),
        queryParams: <String, String>{'id': '$id'});
    return b != null ? b['code'] == 0 : null;
  }

  static Future<Set<Record>> getCrateRecords({limit = 100, offset = 0}) async {
    var b = await sendGet('${URLS.CRATE}${URLS.GET_RECORDS}',
        <String, String>{'limit': '$limit', 'offset': '$offset'});
    Set<Record> ret = Set();
    for (var i in b) {
      ret.add(Record.fromJson(i));
    }
    return ret;
  }

  static Future<Set<Record>> getLaterRecords({limit = 100, offset = 0}) async {
    var b = await sendGet('${URLS.LATER}${URLS.GET_RECORDS}',
        <String, String>{'limit': '$limit', 'offset': '$offset'});
    Set<Record> ret = Set();
    for (var i in b) {
      ret.add(Record.fromJson(i));
    }
    return ret;
  }

  static Future<Set<Record>> getNotesRecords({limit = 100, offset = 0}) async {
    var b = await sendGet('${URLS.NOTES}${URLS.GET_RECORDS}',
        <String, String>{'limit': '$limit', 'offset': '$offset'});
    Set<Record> ret = Set();
    for (var i in b) {
      ret.add(Record.fromJson(i));
    }
    return ret;
  }

  static Future<Set<Record>> getCurrentRecords(
      {limit = 100, offset = 0}) async {
    var b = await sendGet('${URLS.CURRENT}${URLS.GET_RECORDS}',
        <String, String>{'limit': '$limit', 'offset': '$offset'});
    Set<Record> ret = Set();
    for (var i in b) {
      ret.add(Record.fromJson(i));
    }
    return ret;
  }

  static Future<Set<AwaitRecord>> getAwaitRecords(
      {limit = 100, offset = 0}) async {
    var b = await sendGet('${URLS.AWAIT}${URLS.GET_RECORDS}',
        <String, String>{'limit': '$limit', 'offset': '$offset'});
    Set<AwaitRecord> ret = Set();
    for (var i in b) {
      print('AWAIT GET $i');
      var r;
      try {
        r = AwaitRecord.fromJson(i);
        print(r != null ? r.toString() : 'null');
      } catch (e) {
        print('$e');
      }
      ret.add(r);
    }
    return ret;
  }

  static Future<Set<DeadlinedRecord>> getCalendarRecords(
      {limit = 100, offset = 0}) async {
    var b = await sendGet('${URLS.CALENDAR}${URLS.GET_RECORDS}',
        <String, String>{'limit': '$limit', 'offset': '$offset'});
    Set<DeadlinedRecord> ret = Set();
    for (var i in b) {
      print('AWAIT GET $i');
      var r;
      try {
        r = DeadlinedRecord.fromJson(i);
        print(r != null ? r.toString() : 'null');
      } catch (e) {
        print('$e');
      }
      ret.add(r);
    }
    return ret;
  }

  static Future<Record> getLastCrateRecords() async {
    var b = (await sendGet('${URLS.CRATE}${URLS.GET_RECORDS}',
        <String, String>{'limit': '1', 'offset': '0'}));
    return Record.fromJson(b[0]);
  }

  static Future<bool> makeNote(int id, {String newNote}) async {
    var b = await sendPatch('${URLS.NOTES}${URLS.MAKE_NOTE}',
        newNote == null ? null : jsonEncode(<String, String>{'note': newNote}),
        queryParams: <String, String>{'id': '$id'});
    return b != null ? b['code'] == 0 : null;
  }

  static Future<bool> makeDone(int id, {String newNote}) async {
    var b = await sendPatch('${URLS.DONE}${URLS.MAKE_DONE}',
        newNote == null ? null : jsonEncode(<String, String>{'note': newNote}),
        queryParams: <String, String>{'id': '$id'});
    return b != null ? b['code'] == 0 : null;
  }

  static Future<bool> makeCurrent(int id, {String newNote}) async {
    var b = await sendPatch('${URLS.CURRENT}${URLS.MAKE_CURRENT}',
        newNote == null ? null : jsonEncode(<String, String>{'note': newNote}),
        queryParams: <String, String>{'id': '$id'});
    return b != null ? b['code'] == 0 : null;
  }

  static Future<bool> makeLater(int id, {String newNote}) async {
    var b = await sendPatch('${URLS.LATER}${URLS.MAKE_LATER}',
        newNote == null ? null : jsonEncode(<String, String>{'note': newNote}),
        queryParams: <String, String>{'id': '$id'});
    return b != null ? b['code'] == 0 : null;
  }

  static Future<bool> makeAwait(int id, DateTime deadline, String executor,
      {String newNote}) async {
    var body = <String, String>{
      'deadline': misc.formatDateTimeForServer(deadline),
      'executor': executor
    };
    if (newNote != null) {
      body['note'] = newNote;
    }
    var b = await sendPatch('${URLS.AWAIT}${URLS.MAKE_AWAIT}', jsonEncode(body),
        queryParams: <String, String>{'id': '$id'});
    return b != null ? b['code'] == 0 : null;
  }

  static Future<bool> makeProject(
      int id, String doneCriteria, String donePlan, steps,
      {String newNote}) async {
    var body = <String, dynamic>{
      'done_criteria': doneCriteria,
      'done_plan': donePlan,
      'steps': steps
    };
    if (newNote != null) {
      body['note'] = newNote;
    }
    var b = await sendPatch(
        '${URLS.PROJECTS}${URLS.MAKE_PROJECT}', jsonEncode(body),
        queryParams: <String, String>{'id': '$id'});
    return b != null ? b['code'] == 0 : null;
  }

  static Future<bool> makeCalendar(int id, DateTime deadline,
      {String newNote}) async {
    var body = <String, dynamic>{
      'deadline': misc.formatDateTimeForServer(deadline)
    };
    if (newNote != null) {
      body['note'] = newNote;
    }
    var b = await sendPatch(
        '${URLS.CALENDAR}${URLS.MAKE_CALENDAR}', jsonEncode(body),
        queryParams: <String, String>{'id': '$id'});
    return b != null ? b['code'] == 0 : null;
  }

  static get expiringToken => _expiringToken;

  static get longToken => _longToken;
}
