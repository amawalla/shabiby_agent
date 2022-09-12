import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:repair_service_ui/pages/request_service_flow.dart';
import 'package:repair_service_ui/utils/auth.dart';
import 'package:repair_service_ui/utils/helper.dart';
import 'package:repair_service_ui/widgets/input_widget.dart';
import 'package:repair_service_ui/widgets/primary_button.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isLoading = false;
  TextEditingController _username = TextEditingController(text: '');
  TextEditingController _password = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          InputWidget(
            controller: _username,
            hintText: "Namba ya simu / Barua pepe",
            suffixIcon: FlutterIcons.mobile_faw,
          ),
          SizedBox(
            height: 15.0,
          ),
          InputWidget(
            controller: _password,
            hintText: "Namba ya siri",
            obscureText: true,
            suffixIcon: FlutterIcons.lock_ant,
          ),
          SizedBox(
            height: 25.0,
          ),
          PrimaryButton(
            text: "Ingia",
            isLoading: _isLoading,
            onPressed: () async {
              if (_username.text.isNotEmpty && _password.text.isNotEmpty) {
                setState(() {
                  _isLoading = true;
                });
                await attemptLogIn(_username.text, _password.text);
              } else {
                Fluttertoast.showToast(
                    msg:
                        'Tafadhali jaza namba yako ya simu/email pamoja na password',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            },
          ),
          SizedBox(height: 20),
          InkWell(
            onTap: () =>
                Helper.launchURL('https://shabiby.co.tz/dashboard/auth/forgot'),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.only(top: 6, bottom: 4),
              alignment: Alignment.center,
              child: Text(
                "Umesahau namba ya siri ?",
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontFamily: 'narrowmedium',
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
          InkWell(
              onTap: () => Helper.launchURL('https://msafiri.co.tz'),
              child: Center(
                child: Text(
                  'Powered by Msafiri',
                  style: TextStyle(color: Colors.black54),
                ),
              )),
        ],
      ),
    );
  }

  Future<bool> attemptLogIn(String username, String password) async {
    try {
      bool response = await AuthProvider.login(username, password);
      if (response) {
        Phoenix.rebirth(context);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }
}
