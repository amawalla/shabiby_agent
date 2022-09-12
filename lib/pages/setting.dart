//import 'dart:html';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:repair_service_ui/actions/api.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/pages/setting/bluetooth/bluetooth.dart';
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
  String defaultPrinter;
  List<S2Choice<String>> routeChoices;
  final box = GetStorage();

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
    String printer = box.read('bluettoth_device_name');
    setState(() {
      selectedRoute = route;
      defaultPrinter = printer;
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
          applicationType: ApplicationType.material,
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
                  value: Text(defaultPrinter ?? 'Chagua printer ya kutumia'),
                  description: Text('Chagua printer ya kutumia'),
                  onPressed: (e) =>
                      Functions.pushPage(context, BluetoothSetting()),
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
                  title: Text('Ondoa Akaunti'),
                  description: Text('Ondoka kwenye applikesheni'),
                  onPressed: (e) async {
                    showSignOut(context, auth);
                  },
                ),
                SettingsTile(
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Divider(
                          height: 10,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Shabiby Wakala - V1',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    description: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Divider(
                          height: 0,
                          color: Colors.transparent,
                        ),
                        Text('https://www.shabiby.co.tz'),
                        SizedBox(
                          height: 20,
                        ),
                        Text('Powered By Msafiri'),
                      ],
                    )),
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
            'TOA AKAUNTI',
            style: TextStyle(
                color: Constants.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Ungependa kutoa akaunti .?',
          ),
          actions: <Widget>[
            FlatButton(
              textColor: Theme.of(context).accentColor,
              onPressed: () => Navigator.pop(context),
              child: Text('Hapana',
                  style: TextStyle(
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w600)),
            ),
            FlatButton(
              textColor: Colors.red,
              onPressed: () async {
                await auth.logout();
                Phoenix.rebirth(context);
              }, // Go to login
              child: Text('Ndio',
                  style: TextStyle(
                      color: Constants.redColor, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}
