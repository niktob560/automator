import 'package:flutter/material.dart';
import 'package:automator/misc.dart';
import 'package:automator/rest_api/api_service.dart';

class CrateAddStatefulWidget extends StatefulWidget {
  CrateAddStatefulWidget({Key key}) : super(key: key);

  @override
  CrateAddStatefulWidgetState createState() => CrateAddStatefulWidgetState();
}

class CrateAddStatefulWidgetState extends State<CrateAddStatefulWidget> {
  String _textFieldError;
  var _controller = TextEditingController();
  var _progressBarActive = false;

  @override
  Widget build(BuildContext context) {
    return ListView(padding: EdgeInsets.only(left: 32, right: 32), children: [
      const SizedBox(
        height: 32,
      ),
      Text(
        'Add a record',
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      const SizedBox(height: 16),
      TextField(
        decoration: getInputDecoration('Record', _textFieldError),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        controller: _controller,
      ),
      const SizedBox(height: 16),
      (_progressBarActive)
          ? const SizedBox()
          : RaisedButton(
              color: Theme.of(context).accentColor,
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                () async {
                  var valid = true;
                  var message;
                  try {
                    setState(() {
                      if (_controller.text.isEmpty) {
                        _textFieldError = 'Can`t be empty';
                        valid = false;
                      } else if (_controller.text.length < 4) {
                        _textFieldError = 'Must contain at least 4 chars';
                        valid = false;
                      } else {
                        _textFieldError = null;
                      }
                    });
                    if (!valid) return;
                    setState(() {
                      _progressBarActive = true;
                    });
                    var r = await ApiService.postCrate(_controller.text);
                    if (r != null) {
                      if (r) {
                        //success
                        message = 'Successfuly created';
                        _controller.text = '';
                      } else {
                        //what?
                        message = 'An error occured';
                      }
                    } else {
                      //no connection
                      print('Query returned null');
                      message = 'No connection to the server';
                    }
                  } catch (e) {
                    print('$e');
                    message = 'No connection to the server';
                  }
                  setState(() {
                    _progressBarActive = false;
                  });
                  final snackBar = SnackBar(
                    content: Text(message),
                    behavior: SnackBarBehavior.floating,
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                }();
              },
            ),
      Center(
        child: _progressBarActive == true
            ? const CircularProgressIndicator()
            : new Container(),
      ),
      const SizedBox(height: 32),
    ]);
  }
}
