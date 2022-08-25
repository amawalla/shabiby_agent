//import 'dart:html';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:repair_service_ui/actions/api.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/pages/user/profile.dart';
import 'package:repair_service_ui/utils/constants.dart';
import 'package:repair_service_ui/utils/session.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_select/smart_select.dart';

import '../../utils/auth.dart';
import '../utils/functions.dart';
import 'home.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  int counter = 0;
  User user;
  bool dataIsLoading = true;
  bool useNotificationDotOnAppIcon = true;
  RouteModel route;
  String selectedRoute;
  List<S2Choice<String>> routeChoices;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        Provider.of<AuthProvider>(context, listen: false).setUser();
      },
    );

    this._initialize();
  }

  Future<dynamic> _initialize() async {
    String route = await Session().get('default_route_name');
    setState(() {
      selectedRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder: (BuildContext context, auth, Widget child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: Text(
            'Mipangilio',
          ),
        ),
        body: SettingsList(
          applicationType: ApplicationType.both,
          platform: DevicePlatform.android,
          sections: [
            SettingsSection(
              title: Text(
                'Tiketi',
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w600),
              ),
              tiles: [
                SettingsTile(
                    title: Text('Safari yangu'),
                    value: Text(selectedRoute ?? 'Hakuna'),
                    description: Text('Chagua safari yako ya kila siku')),
              ],
            ),
            SettingsSection(
              title: Text(
                'Printer',
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w600),
              ),
              tiles: [
                SettingsTile(
                  title: Text('Bluetooth'),
                  description: Text('Chagua printer ya kutumia'),
                ),
                SettingsTile(
                  title: Text('Thermal'),
                  description: Text(
                    'Boresha rangi, muonekano na ukubwa wa maneno',
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: Text(
                'Akaunti',
                style: TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w600),
              ),
              tiles: [
                SettingsTile(
                  title: Text(auth.user.firstName + ' ' + auth.user.lastName),
                  description: Text('Hariri taarifa zako'),
                  onPressed: (e) async {
                    return await Functions.pushPage(context, Profile());
                  },
                ),
                SettingsTile(
                  title: Text('Sign out'),
                  description: Text('Ondoka kwenye applikesheni'),
                  onPressed: (e) async {
                    showSignOut(context, auth);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  showSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            'SIGN OUT',
            style: TextStyle(
                color: Constants.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Do you want to sign out .?',
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).accentColor,
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w600)),
            ),
            FlatButton(
              textColor: Colors.red,
              onPressed: () async {
                await auth.logout();

                Navigator.pushAndRemoveUntil<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => Home(),
                  ),
                  (route) =>
                      false, //if you want to disable back feature set to false
                );
              }, // Go to login
              child: Text('Confirm',
                  style: TextStyle(
                      color: Constants.redColor, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
