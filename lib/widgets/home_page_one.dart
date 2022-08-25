// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:repair_service_ui/actions/api.dart';
import 'package:repair_service_ui/pages/booking/booking.dart';
import 'package:repair_service_ui/pages/home.dart';
import 'package:repair_service_ui/pages/scanner.dart';
import 'package:repair_service_ui/pages/schedule/index.dart';
import 'package:repair_service_ui/pages/setting.dart';
import 'package:repair_service_ui/pages/user/profile.dart';
import 'package:repair_service_ui/utils/auth.dart';
import 'package:repair_service_ui/utils/constants.dart';
import 'package:repair_service_ui/utils/functions.dart';
import 'package:repair_service_ui/widgets/page_indicator.dart';
import '../models/model.dart';

class HomePageOne extends StatefulWidget {
  final Function nextPage;
  final Function prevPage;

  HomePageOne({this.nextPage, this.prevPage});

  @override
  _HomePageOneState createState() => _HomePageOneState();
}

const double fixPadding = 10.0;

class _HomePageOneState extends State<HomePageOne> {
  bool _isLoading = false;
  TextEditingController _ticketNo = TextEditingController(text: null);

  MobileScannerController _scannerController = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
    facing: CameraFacing.back,
  );

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        Provider.of<AuthProvider>(context, listen: false).setUser();
      },
    );
  }

  final List options = [
    [
      {
        "name": "Kata Tiketi",
        "icon": "assets/svg/bus.svg",
        "key": "mobile",
        "width": 80,
        "height": 80,
        'page': 'book',
      },
      {
        "name": "Hakiki Tiketi",
        "icon": "assets/svg/scanner.svg",
        "key": "tablet",
        'page': 'search',
        "width": 75,
        "height": 75,
      },
    ],
    // Second
    [
      {
        "name": "Ratiba za Mabasi",
        "icon": "assets/svg/schedule.svg",
        "key": "laptop",
        'page': 'schedule',
        "width": 80,
        "height": 80,
      },
      {
        "name": "Tafuta Tiketi",
        "icon": "assets/svg/pos.svg",
        "key": "desktop",
        'page': 'print',
        "width": 90,
        "height": 90,
      },
    ],
    // Third
    [
      {
        "name": "Akaunti",
        "icon": "assets/svg/profile.svg",
        "key": "watch",
        'page': 'profile',
        "width": 80,
        "height": 80,
      },
      {
        "name": "Mipangilio",
        "icon": "assets/svg/setting.svg",
        "key": "headphone",
        'page': 'setting',
        "width": 80,
        "height": 80,
      },
    ],
  ];

  String active = "";

  void setActiveFunc(String key) {
    setState(() {
      active = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double heightFromWhiteBg =
        size.height - 150.0 - Scaffold.of(context).appBarMaxHeight;
    return Consumer<AuthProvider>(
        builder: (BuildContext context, auth, Widget child) {
      return Container(
        color: Colors.redAccent.shade200.withOpacity(0.9),
        height: size.height - kToolbarHeight,
        child: Stack(
          children: [
            Container(
              height: 170.0,
              width: size.width,
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
              child: FittedBox(
                child: Container(
                  width: size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PageIndicator(activePage: 1),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Habari, " + (auth != null ? auth.user.firstName : ''),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Chagua huduma",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35.0,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150.0,
              width: size.width,
              child: Container(
                height: heightFromWhiteBg,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40.0),
                    topRight: Radius.circular(40.0),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 150.0,
              height: heightFromWhiteBg,
              width: size.width,
              child: Container(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: index == 2 ? 0 : 10.0),
                        child: Row(
                          children: [
                            serviceCard(
                                options[index][0],
                                active,
                                setActiveFunc,
                                this.widget.nextPage,
                                context,
                                auth),
                            SizedBox(
                              width: 10.0,
                            ),
                            serviceCard(
                                options[index][1],
                                active,
                                setActiveFunc,
                                this.widget.nextPage,
                                context,
                                auth),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  _renderIndicator() {
    return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
            backgroundColor: Colors.transparent));
  }

  _showPrintTicketModal(BuildContext context) {
    showBarModalBottomSheet(
        backgroundColor: Colors.white,
        useRootNavigator: true,
        elevation: 3,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context,
              StateSetter setNewState /*You can rename this!*/) {
            return SingleChildScrollView(
              controller: ModalScrollController.of(context),
              child: Container(
                height: 550,
                color: Colors.white,
                child: ListView(
                  children: <Widget>[
                    Material(
                        shadowColor: Colors.grey.shade300,
                        elevation: 7,
                        child: Container(
                          color: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Column(children: [
                            const Center(
                                child: Text(
                              'TAFUTA TIKETI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                                fontWeight: FontWeight.w700,
                              ),
                            )),
                            const SizedBox(height: 5.0),
                          ]),
                        )),
                    const SizedBox(height: 25),
                    const SizedBox(height: 20),
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextFormField(
                              controller: _ticketNo,
                              keyboardType: TextInputType.number,
                              cursorColor: Colors.teal,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                border: OutlineInputBorder(),
                                hintText: "914XXXXXX",
                                hintStyle: TextStyle(
                                  color: Color(0xFFC2C2C2),
                                  fontSize: 30,
                                  fontFamily: "narrownews",
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 30,
                                fontFamily: "narrownews",
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 40),
                            child: Center(
                              child: Text(
                                'Ingiza namba ya tiketi, mfano:  914XXXXXX',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  height: 1.5,
                                  color:
                                      Theme.of(context).textTheme.caption.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.redAccent.withOpacity(0.9)),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 10)),
                            ),
                            onPressed: () async {
                              try {
                                setNewState(() {
                                  _isLoading = true;
                                });

                                BookingModel booking =
                                    await Api.getBooking(_ticketNo.text);
                                if (booking != null) {
                                  setNewState(() {
                                    _isLoading = false;
                                  });
                                  Functions.pushPage(
                                      context, BookingShow(booking: booking));
                                }

                                setNewState(() {
                                  _isLoading = false;
                                });
                              } catch (e) {
                                AlertDialog(
                                  title: Text('Error'),
                                  content: Text(e.toString()),
                                );
                                print(e.toString());
                                setNewState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            child: _isLoading
                                ? _renderIndicator()
                                : const Text(
                                    'CHAPA TICKET',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ))
                  ],
                ),
              ),
            );
          });
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
                return await Functions.pushPage(context, Home());
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

  divider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: fixPadding * 2.0),
      color: Constants.greyColor.withOpacity(0.5),
      height: 1,
      width: double.infinity,
    );
  }

  getItemAction(item, nextPage, BuildContext context, AuthProvider auth) {
    switch (item['page']) {
      case 'book':
        return Future.delayed(Duration(milliseconds: 100), () {
          nextPage();
        });
      case 'search':
        return Functions.pushPage(context, Scanner());
      case 'schedule':
        return Functions.pushPage(context, SchedulePage());
      case 'print':
        return _showPrintTicketModal(context);
      case 'profile':
        return Functions.pushPage(context, Profile());
      case 'setting':
        return Functions.pushPage(context, Setting());
    }
  }

  Widget serviceCard(Map item, String active, Function setActive, nextPage,
      BuildContext context, AuthProvider auth) {
    bool isActive = active == item["key"];
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setActive(item["key"]);
          getItemAction(item, nextPage, context, auth);
          // Future.delayed(Duration(milliseconds: 350), () {
          // nextPage();
          //});
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: isActive ? Colors.redAccent : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                item["icon"],
                color: isActive ? Colors.white : Colors.redAccent,
                width: double.parse(item['width'].toString()),
                height: double.parse(item['height'].toString()),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                item["name"],
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.0,
                    color: isActive ? Colors.white : Colors.black87),
              )
            ],
          ),
        ),
      ),
    );
  }
}
