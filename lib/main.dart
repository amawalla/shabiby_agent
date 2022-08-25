import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:repair_service_ui/models/setting_provider.dart';
import 'package:repair_service_ui/pages/request_service_flow.dart';
import 'package:repair_service_ui/utils/auth.dart';
import 'package:repair_service_ui/utils/constants.dart';
import 'package:repair_service_ui/pages/home.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

void main() async {
  //await checkInternetConnection(InternetConnectionChecker());
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
        headerBuilder: () => MaterialClassicHeader(),
        footerBuilder: () => ClassicFooter(),
        headerTriggerDistance: 80.0,
        springDescription:
            SpringDescription(stiffness: 170, damping: 16, mass: 1.9),
        // custom spring back animate,the props meaning see the flutter api
        maxOverScrollExtent: 100,
        //The maximum dragging range of the head. Set this property if a rush out of the view area occurs
        maxUnderScrollExtent: 0,
        // Maximum dragging range at the bottom
        enableScrollWhenRefreshCompleted: true,
        enableLoadingWhenFailed: true,
        hideFooterWhenNotFull: false,
        enableBallisticLoad: true,
        child: ScreenUtilInit(
          designSize: Size(375, 812),
          builder: (context, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shabiby POS',
            theme: ThemeData(
              primaryColor: Constants.redColor,
              scaffoldBackgroundColor: Color.fromRGBO(255, 255, 255, 1),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              textTheme: GoogleFonts.robotoCondensedTextTheme(),
            ),
            initialRoute: '/',
            onGenerateRoute: (e) => _onGenerateRoute(e),
            builder: EasyLoading.init(),
          ),
        ));
  }
}

Future<void> checkInternetConnection(
  InternetConnectionChecker internetConnectionChecker,
) async {
  // Simple check to see if we have Internet
  // ignore: avoid_print
  print('''The statement 'this machine is connected to the Internet' is: ''');
  final bool isConnected = await InternetConnectionChecker().hasConnection;
  // ignore: avoid_print
  print(
    isConnected.toString(),
  );

  if (!isConnected) {
    SnackBar(content: const Text('Tafadhali hakikisha ume connect internet'));
  }
  // returns a bool

  // We can also get an enum instead of a bool
  // ignore: avoid_print
  print(
    'Current status: ${await InternetConnectionChecker().connectionStatus}',
  );
  // Prints either InternetConnectionStatus.connected
  // or InternetConnectionStatus.disconnected

  // actively listen for status updates
  final StreamSubscription<InternetConnectionStatus> listener =
      InternetConnectionChecker().onStatusChange.listen(
    (InternetConnectionStatus status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          break;
        case InternetConnectionStatus.disconnected:
          SnackBar(
              content: const Text('Tafadhali hakikisha ume connect internet'));
          break;
      }
    },
  );

  // close listener after 30 seconds, so the program doesn't run forever
  await Future<void>.delayed(const Duration(seconds: 3));
  await listener.cancel();
}

Route<dynamic> _onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (BuildContext context) {
        return Home();
      });
    case "home":
      return MaterialPageRoute(builder: (BuildContext context) {
        return RequestServiceFlow();
      });
    case "login":
      return MaterialPageRoute(builder: (BuildContext context) {
        return Home();
      });
    default:
      return MaterialPageRoute(builder: (BuildContext context) {
        return RequestServiceFlow();
      });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
