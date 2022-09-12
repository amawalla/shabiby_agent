import 'dart:convert';

import 'package:device_information/device_information.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:repair_service_ui/actions/api.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/pages/request_service_flow.dart';
import 'package:repair_service_ui/pages/user/login.dart';
import 'package:repair_service_ui/utils/session.dart';
import 'package:splashscreen/splashscreen.dart';

class Home extends StatelessWidget {
  final box = GetStorage();

  Future<Widget> redirectIfAutheticated() async {
    bool isLogged = await Session().isLoggedIn();
    try {
      box.write('device_model', await DeviceInformation.deviceModel);
      box.write(
          'is_printer', await DeviceInformation.deviceManufacturer == 'SUNMI');
      if (isLogged) {
        print('Initialising resources');
        await initilizeResources();
      }

      print(isLogged);
    } catch (e) {
      print(e);
    }

    return Future.value(isLogged ? RequestServiceFlow() : LoginPage());
  }

  Future initilizeResources() async {
    List<RouteModel> routes = await Api.getRoutes();
    if (routes != null) {
      print('Routes loaded');
      box.write('routes', json.encode(routes.map((e) => e.toJson()).toList()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 4,
        navigateAfterFuture: redirectIfAutheticated(),
        title: richText(19),
        image: new Image.asset('assets/images/msafiri-white.png'),
        backgroundColor: Colors.redAccent,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        loadingText: Text(
          'Tafadhali subiri...',
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        onClick: () => print("Flutter Egypt"),
        loaderColor: Colors.white);
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 30.12,
          color: Colors.white,
          letterSpacing: 1.999999953855673,
        ),
        children: const [
          TextSpan(
            text: 'SHABIBY',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'LINE',
            style: TextStyle(
              color: Color(0xFFFE9879),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
