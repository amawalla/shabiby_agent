import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:repair_service_ui/utils/constants.dart';
import 'package:repair_service_ui/widgets/home_page_one.dart';
import 'package:repair_service_ui/widgets/home_page_two.dart';

class RequestServiceFlow extends StatefulWidget {
  @override
  _RequestServiceFlowState createState() => _RequestServiceFlowState();
}

class _RequestServiceFlowState extends State<RequestServiceFlow> {
  int current = 0;

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
      HomePageTwo(nextPage: nextPage, prevPage: prevPage),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          current == 1 ? 'TIKETI' : 'SHABIBY LINE',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        brightness: Brightness.light,
        elevation: 4.0,
        backgroundColor: Colors.redAccent,
        leading: current > 0
            ? GestureDetector(
                onTap: () {
                  this.prevPage();
                },
                child: Icon(FlutterIcons.keyboard_backspace_mdi,
                    color: Colors.white),
              )
            : null,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: current == 0 ? Constants.primaryColor : Colors.white,
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: pages[current],
      ),
    );
  }
}
