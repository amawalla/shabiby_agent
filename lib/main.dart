import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:repair_service_ui/models/setting_provider.dart';
import 'package:repair_service_ui/utils/auth.dart';
import 'package:repair_service_ui/utils/constants.dart';
import 'package:repair_service_ui/pages/home.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  await GetStorage.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    ],
    child: Phoenix(child: MyApp()),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: (context, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shabiby WAKALA',
          theme: ThemeData(
            primaryColor: Constants.redColor,
            scaffoldBackgroundColor: Color.fromRGBO(255, 255, 255, 1),
            visualDensity: VisualDensity.adaptivePlatformDensity,
            textTheme: GoogleFonts.robotoCondensedTextTheme(),
          ),
          builder: EasyLoading.init(),
          home: Home()),
    );
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
