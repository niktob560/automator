import 'package:automator/prefs.dart';
import 'package:automator/rest_api/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'misc.dart';

class ConfigurerWidget extends StatefulWidget {
  @override
  State createState() => _ConfigurerWidgetState();
}

enum _State { idle, loading, failed }

class _ConfigurerWidgetState extends State<ConfigurerWidget> {
  String _hostError, _tokenError;
  TextEditingController _hostController = TextEditingController(),
      _tokenController = TextEditingController();

  _State _state = _State.idle;

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
            decoration: getInputDecoration('Host', _hostError),
            controller: _hostController,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            enabled: (_state != _State.loading),
          ),
          const SizedBox(height: 32),
          TextField(
            decoration: getInputDecoration('Token', _tokenError),
            controller: _tokenController,
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
                        var host = _hostController.text;
                        var token = _tokenController.text;
                        setState(() {
                          if (host == null || host.isEmpty)
                            _hostError = 'Can`t be empty';
                          else {
                            bool valid;
                            try {
                              valid = Uri.parse(host).isAbsolute;
                            } catch (e) {
                              valid = false;
                            }
                            _hostError = valid ? null : 'Uri invalid';
                          }
                          if (token == null || token.isEmpty)
                            _tokenError = 'Can`t be empty';
                          else
                            _tokenError = null;
                        });
                        if (_hostError == null && _tokenError == null) {
                          setState(() {
                            _state = _State.loading;
                          });
                          print('Trying to connect $host $token');
                          bool valid;

                          try {
                            valid = await ApiService.login(token, host);
                            if (valid)
                              await PreferenceManager.auth(host, token);
                          } catch (e) {
                            print('$e');
                            valid = false;
                          }
                          print('${valid ? 'success' : 'fail'}');
                          if (!valid)
                            setState(() {
                              _state = _State.failed;
                            });
                        }
                      },
                    )
                  : const CircularProgressIndicator())
        ], padding: EdgeInsets.all(16)),
      ));
}
