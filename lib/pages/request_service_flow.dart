import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_service_ui/utils/constants.dart';
import 'package:repair_service_ui/widgets/home_page_one.dart';
import 'package:upgrader/upgrader.dart';
import '../utils/double_back.dart';

class RequestServiceFlow extends StatefulWidget {
  @override
  _RequestServiceFlowState createState() => _RequestServiceFlowState();
}

class _RequestServiceFlowState extends State<RequestServiceFlow> {
  int current = 0;
  final box = GetStorage();

  void nextPage() {
    setState(() {
      current += 1;
    });
  }

  void prevPage() {
    setState(() {
      current -= 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      HomePageOne(nextPage: nextPage, prevPage: prevPage),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/shabiby-logo.png',
          fit: BoxFit.contain,
          height: 40.0,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        elevation: 4.0,
        backgroundColor: Colors.redAccent,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: current == 0 ? Constants.primaryColor : Colors.white,
      body: DoubleBack(
        message: "Press back again to close",
        waitForSecondBackPress: 3,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: UpgradeAlert(
              upgrader: Upgrader(
                  debugLogging: false,
                  durationUntilAlertAgain: Duration(days: 3),
                  debugDisplayAlways: false,
                  showReleaseNotes: true),
              child: pages[current]),
        ),
        textStyle: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
        background: Colors.black54,
        backgroundRadius: 30,
      ),
    );
  }
}
