import 'dart:convert';

import 'package:automator/prefs.dart';
import 'package:automator/rest_api/api_service.dart';
import 'package:flutter/material.dart';

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
        child: ListView(children: [
          const SizedBox(height: 32),
          TextField(
            decoration: getInputDecoration('Config string', _configError),
            controller: _configController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            enabled: (_state != _State.loading),
          ),
          const SizedBox(height: 32),
          (_state == _State.failed
              ? Text('Failed to connect',
                  style: TextStyle(color: Theme.of(context).errorColor))
              : const SizedBox()),
          const SizedBox(height: 32),
          Center(
              child: _state != _State.loading
                  ? RaisedButton(
                      child: Text('Done'),
                      onPressed: () async {
                        setState(() {
                          _configError = null;
                          _state = _State.loading;
                        });
                        try {
                          final config =
                              jsonDecode(_codec.decode(_configController.text));
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
                          }
                          else {
                            //valid config
                            if (await ApiService.login(token, host)) {
                              await PreferenceManager.auth(host, token);
                            }
                            else {
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
                      },
                    )
                  : const CircularProgressIndicator())
        ], padding: EdgeInsets.all(16)),
      ));
}
