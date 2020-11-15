import 'dart:convert';
import 'dart:ui';
import 'dart:math';

import 'package:automator/prefs.dart';
import 'package:automator/rest_api/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:qrscan/qrscan.dart' as scanner;

import 'misc.dart';

class ConfigurerWidget extends StatefulWidget {
  @override
  State createState() => _ConfigurerWidgetState();
}

enum _State { idle, loading, failed }

class _ConfigurerWidgetState extends State<ConfigurerWidget> {
  String _configError;
  TextEditingController _configController = TextEditingController();
  _State _state = _State.idle;
  static final _codec = utf8.fuse(base64);
  bool _showConfigClear = false;

  static const _sigmaX = 2.0; // from 0-10
  static const _sigmaY = 2.0; // from 0-10
  static const _opacity = 0.1; // from 0-1.0

  @override
  void initState() {
    _configController.addListener(() {
      var newBool =
          (_configController.text != null && _configController.text.isNotEmpty);
      if (newBool != _showConfigClear)
        setState(() {
          _showConfigClear = newBool;
        });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Center(
              child: Text(
        'Please, configure server settings',
        style: TextStyle(
            color: Colors.white, fontSize: 24, decoration: TextDecoration.none),
        textAlign: TextAlign.center,
      ))),
      body: Container(
          decoration: BoxDecoration(color: Theme.of(context).backgroundColor),
          child: Stack(
            children: [
              ListView(children: [
                const SizedBox(height: 32),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        child: IconButton(
                            icon: Icon(Icons.qr_code),
                            onPressed: () async {
                              if (_state != _State.loading) {
                                final conf = await scanner.scan();
                                _configController.text = conf;
                                _login(conf);
                              }
                            }),
                        decoration: BoxDecoration(
                            color: Theme.of(context).buttonColor,
                            borderRadius: BorderRadius.all(Radius.circular(2))),
                        alignment: Alignment.topCenter,
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                          child: TextField(
                        decoration:
                            getInputDecoration('Config string', _configError)
                                .copyWith(
                                    suffixIcon: (_showConfigClear)
                                        ? IconButton(
                                            icon: Icon(Icons.clear),
                                            onPressed: () {
                                              _configController.clear();
                                              setState(() {
                                                _configError = null;
                                              });
                                            })
                                        : const SizedBox()),
                        controller: _configController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      )),
                    ]),
                const SizedBox(height: 32),
                Center(
                    child: RaisedButton(
                        child: Text('Done'),
                        onPressed: () => _login(_configController.text)))
              ], padding: EdgeInsets.all(16)),
              (_state == _State.loading)
                  ? Container(
                      // width: min(MediaQuery.of(context).size.height,
                      //         MediaQuery.of(context).size.width) *
                      //     0.5,
                      // height: min(MediaQuery.of(context).size.height,
                      //         MediaQuery.of(context).size.width) *
                      //     0.5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: BackdropFilter(
                        filter:
                            ImageFilter.blur(sigmaX: _sigmaX, sigmaY: _sigmaY),
                        child: Center(
                            child: Container(
                          width: min(MediaQuery.of(context).size.height,
                                  MediaQuery.of(context).size.width) *
                              0.5,
                          height: min(MediaQuery.of(context).size.height,
                                  MediaQuery.of(context).size.width) *
                              0.5,
                          // color: Colors.black.withOpacity(_opacity),
                          child: CircularProgressIndicator(),
                        )),
                      ))
                  : const SizedBox()
            ],
          )));

  _login(final String conf) async {
    setState(() {
      _configError = null;
      _state = _State.loading;
    });
    try {
      final config = jsonDecode(_codec.decode(conf));
      final String host = config['host'];
      final String token = config['token'];
      if (config == null || config.isEmpty) {
        //if no config provided
        setState(() {
          _configError = 'Can`t be empty';
          _state = _State.failed;
        });
        return;
      } else if (host == null ||
          host.isEmpty ||
          token == null ||
          token.isEmpty ||
          !Uri.parse(host).isAbsolute) {
        //if invalid connection data provided
        setState(() {
          _configError = 'Invalid config';
          _state = _State.failed;
        });
        return;
      } else {
        //valid config
        if (await ApiService.login(token, host)) {
          await PreferenceManager.auth(host, token);
        } else {
          //invalid login
          setState(() {
            _configError = 'Invalid credentials';
            _state = _State.failed;
          });
        }
      }
    } catch (e) {
      //system error on some step
      setState(() {
        _configError = 'Invalid config format';
        _state = _State.failed;
      });
      return;
    }
  }
}
