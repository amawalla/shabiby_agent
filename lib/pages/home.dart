import 'package:flutter/material.dart';
import 'package:repair_service_ui/pages/request_service_flow.dart';
import 'package:repair_service_ui/pages/user/login.dart';
import 'package:repair_service_ui/utils/auth.dart';
import 'package:repair_service_ui/utils/session.dart';
import 'package:splashscreen/splashscreen.dart';

class Home extends StatelessWidget {
  Future<Widget> redirectIfAutheticated() async {
    bool isLogged = await Session().isLoggedIn();
    if (isLogged) {
      bool isRefreshed = await AuthProvider().refresh();
      isLogged = isRefreshed;
    }
    return Future.value(isLogged ? RequestServiceFlow() : LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        seconds: 4,
        navigateAfterFuture: redirectIfAutheticated(),
        title: new Text(
          'SHABIBY TRANSPORT',
          style: new TextStyle(
              fontWeight: FontWeight.w900, fontSize: 30.0, color: Colors.white),
        ),
        image: new Image.asset('assets/images/msafiri-white.png'),
        backgroundColor: Colors.redAccent,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 150.0,
        loadingText: Text(
          'Tafadhali subiri...',
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        onClick: () => print("Flutter Egypt"),
        loaderColor: Colors.white);
  }
}
