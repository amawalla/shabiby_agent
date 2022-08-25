//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:repair_service_ui/actions/api.dart';
import 'package:repair_service_ui/models/model.dart';

import '../../utils/auth.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int counter = 0;
  User user;
  bool dataIsLoading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        Provider.of<AuthProvider>(context, listen: false).setUser();
      },
    );
    _getUserData();
  }

  Future<dynamic> _getUserData() async {
    User userResponse = await Api.getUser();
    if (userResponse != null) {
      setState(() {
        dataIsLoading = false;
        user = userResponse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
        builder: (BuildContext context, auth, Widget child) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.redAccent,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.redAccent, Colors.redAccent.shade200],
                      ),
                    ),
                    child: Column(children: [
                      SvgPicture.asset(
                        'assets/svg/profile.svg',
                        color: Colors.white,
                        width: 100,
                        height: 100,
                      ),
                      Text(auth.user.firstName + ' ' + auth.user.lastName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          )),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        auth.user.email,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.0,
                        ),
                      )
                    ]),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Container(
                    color: Colors.grey[200],
                    child: Center(
                        child: Card(
                            elevation: 3,
                            margin: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
                            child: Container(
                                width: 310.0,
                                height: 290.0,
                                child: Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 5),
                                      Text(
                                        "Taarifa fupi",
                                        style: TextStyle(
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Divider(
                                        color: Colors.grey[300],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.account_circle,
                                            color: Colors.redAccent.shade200,
                                            size: 35,
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Jina lako",
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color:
                                                        Colors.grey.shade700),
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                auth.user.firstName +
                                                    ' ' +
                                                    auth.user.lastName,
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.black87,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.phone_android,
                                            color: Colors.redAccent.shade200,
                                            size: 35,
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Namba ya simu",
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color:
                                                        Colors.grey.shade700),
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                auth.user.phone,
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.black87,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.email,
                                            color: Colors.redAccent.shade200,
                                            size: 35,
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Barua pepe",
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color:
                                                        Colors.grey.shade700),
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                auth.user.email,
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.black87,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.people,
                                            color: Colors.redAccent.shade200,
                                            size: 35,
                                          ),
                                          SizedBox(
                                            width: 20.0,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Jukumu/Kazi",
                                                style: TextStyle(
                                                    fontSize: 15.0,
                                                    color:
                                                        Colors.grey.shade700),
                                              ),
                                              SizedBox(height: 3),
                                              Text(
                                                auth.user.roles ?? 'Wakala',
                                                style: TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.black87,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )))),
                  ),
                ),
              ],
            ),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                left: 20.0,
                right: 20.0,
                child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              child: Column(
                            children: [
                              Text(
                                'LEO',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w900),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              dataIsLoading
                                  ? SizedBox(
                                      height: 10,
                                      width: 10,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 1,
                                          color: Colors.redAccent),
                                    )
                                  : Text(
                                      (user != null
                                              ? user.data.todayTickets
                                              : auth.user.data.todayTickets)
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600),
                                    )
                            ],
                          )),
                          Container(
                            child: Column(children: [
                              Text(
                                DateFormat.MMMM()
                                    .format(DateTime.now())
                                    .toUpperCase(),
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w900),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              dataIsLoading
                                  ? SizedBox(
                                      height: 10,
                                      width: 10,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 1,
                                          color: Colors.redAccent))
                                  : Text(
                                      (user != null
                                              ? user.data.totalMonthlyTickets
                                              : auth.user.data
                                                  .totalMonthlyTickets)
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600),
                                    )
                            ]),
                          ),
                          Container(
                              child: Column(
                            children: [
                              Text(
                                'JUMLA',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w900),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              dataIsLoading
                                  ? SizedBox(
                                      height: 10,
                                      width: 10,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 1,
                                          color: Colors.redAccent))
                                  : Text(
                                      (user != null
                                              ? user.data.totalTickets
                                              : auth.user.data.totalTickets)
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600),
                                    )
                            ],
                          )),
                        ],
                      ),
                    )))
          ],
        ),
      );
    });
  }
}
