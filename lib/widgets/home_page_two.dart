import 'dart:async';
import 'dart:convert';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:cool_stepper/cool_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/models/setting_provider.dart';
import 'package:repair_service_ui/pages/request_service_flow.dart';
import 'package:repair_service_ui/utils/functions.dart';
import 'package:repair_service_ui/utils/helper.dart';
import 'package:repair_service_ui/utils/session.dart';
import 'package:smart_select/smart_select.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:repair_service_ui/actions/api.dart';

class HomePageTwo extends StatefulWidget {
  final Function nextPage;
  final Function prevPage;

  HomePageTwo({this.nextPage, this.prevPage});

  @override
  _HomePageTwoState createState() => _HomePageTwoState();
}

class _HomePageTwoState extends State<HomePageTwo> {
  final _formKey = GlobalKey<FormState>();
  final _passengerFormKey = GlobalKey<FormState>();
  String selectedMethod = 'cash';
  TextEditingController _travelDate = TextEditingController(text: null);
  TextEditingController _route = TextEditingController(text: null);
  TextEditingController _schedule = TextEditingController(text: null);
  DateRangePickerController _rangePickerController =
      DateRangePickerController();
  int seatNumber;
  bool scheduleIsLoading = false;
  bool scheduleIsEnabled = true;
  ScheduleModel selectedSchedule;
  RouteModel selectedRoute;
  List<ScheduleModel> scheduleResponse;
  List routes;
  List<S2Choice<String>> schedules;
  List<S2Choice<String>> boardingPoints;
  List<S2Choice<String>> droppingPoints;
  List<S2Choice<String>> choices;
  List selectedSeats = [];
  List<PassengerModel> passengers = [];
  String passengerMessage;
  bool passengerError = false;
  String active = "";
  bool routeIsLoaded = false;
  bool isSubmitting = false;
  dynamic defaultRoute;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _initializeProcess();
    });
  }

  Future refreshSchedule() async {
    if (selectedSchedule != null && _schedule.text != null) {
      setState(() {
        scheduleIsLoading = true;
      });
      await Api.getSchedule(selectedSchedule.scheduleNo).then((value) {
        if (value != null && value.scheduleNo == selectedSchedule.scheduleNo) {
          setState(() {
            selectedSchedule = value;
            scheduleIsLoading = false;
          });
        }
      });
    }
  }

  Future fetchSchedules() async {
    if (_route.text.isNotEmpty && _travelDate.text.isNotEmpty) {
      setState(() {
        scheduleIsEnabled = false;
        scheduleIsLoading = true;
        _schedule..text = '';
      });

      scheduleResponse =
          await Api.fetchSchedules(_travelDate.text, _route.text);

      if (scheduleResponse != null) {
        setState(() {
          schedules = scheduleResponse
              .map((item) =>
                  S2Choice<String>(value: item.scheduleNo, title: item.name))
              .toList();
          scheduleIsEnabled = true;
          scheduleIsLoading = false;
        });
      }
    }
  }

  Future<dynamic> _initializeProcess() async {
    dynamic storeRoutes = box.read('routes');
    List<RouteModel> response;
    if (storeRoutes == null) {
      response = await Api.getRoutes();
    } else {
      List data = json.decode(storeRoutes);
      response = data
          .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (response != null) {
      defaultRoute = await Session().get('default_route');
      setState(() {
        routes = response;
        selectedRoute = defaultRoute != null
            ? routes.firstWhere((element) => element.id == defaultRoute)
            : null;
        _route..text = defaultRoute != null ? defaultRoute.toString() : null;
        _rangePickerController.selectedDate = DateTime.now();
        _travelDate..text = _rangePickerController.selectedDate.toString();
        choices = routes
            .map((item) =>
                S2Choice<String>(value: item.id.toString(), title: item.name))
            .toList();
      });

      await fetchSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder:
        (BuildContext context, SettingProvider provider, Widget child) {
      Size size = MediaQuery.of(context).size;
      return LoadingOverlay(
          color: Colors.redAccent.withOpacity(0.8),
          progressIndicator: SpinKitRing(color: Colors.white, size: 50.0),
          isLoading: scheduleIsLoading || isSubmitting,
          child: Container(
            width: size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: buildStepWizard(context),
                ),
              ],
            ),
          ));
    });
  }

  buildStepWizard(BuildContext context) {
    final bookingSteps = [
      CoolStep(
        title: 'Taarifa ya Safari',
        subtitle: 'Jaza safari, tarehe na mda wa kuondoka',
        content: Form(
          key: _formKey,
          child: _stepOne(_formKey),
        ),
        validation: () {
          if (_schedule.text.isEmpty) {
            Fluttertoast.showToast(
              msg: 'Tafadhali jaza taarifa zote zinazohitaji',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
            return 'Tafadhali jaza taarifa zote zinazohitaji';
          }
          return null;
        },
      ),
      CoolStep(
        title: 'CHAGUA KITI',
        subtitle: selectedSchedule?.name,
        content: Column(
          children: [
            SizedBox(height: 5),
            Text(
              selectedSchedule?.seatLayout ?? ' ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            selectedSchedule != null
                ? _renderBusSeats(selectedSchedule)
                : SizedBox(height: 10),
          ],
        ),
        validation: () {
          if (selectedSeats.isEmpty) {
            Fluttertoast.showToast(
              msg: 'Tafadhali chagua siti/viti kuendelea',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
            return 'Tafadhali chagua siti/viti kuendelea';
          }
          return null;
        },
      ),
      CoolStep(
        title: 'TAARIFA ZA ABIRIA',
        subtitle: 'Jaza taarifa muhimu za abiria kuendelea',
        content: Form(key: _passengerFormKey, child: renderPassengerFields()),
        validation: () {
          if (!_passengerFormKey.currentState.validate()) {
            Fluttertoast.showToast(
              msg: 'Tafadhali jaza taarifa za abiria',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
            return 'Tafadhali jaza taarifa za abiri';
          }
          return null;
        },
      ),
      CoolStep(
        title: 'HAKIKI TAARIFA',
        subtitle: 'Hakiki taarifa kisha bonyeza WEKA TIKETI',
        content: renderConfirmScreen(),
        validation: () {
          if (selectedMethod.isEmpty) {
            Fluttertoast.showToast(
              msg: 'Tafadhali chagua aina ya malipo',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
            return 'Tafadhali chagua aina ya malipo';
          }
          return null;
        },
      ),
    ];
    return CoolStepper(
      showErrorSnackbar: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      onCompleted: () {
        showAdaptiveActionSheet(
          context: context,
          title: Text('HAKIKI & PRINT'),
          androidBorderRadius: 30,
          isDismissible: true,
          actions: <BottomSheetAction>[
            BottomSheetAction(
                title: const Text('WASILISHA PEKEE'),
                onPressed: (context) async {
                  await submit(false);
                  //  Helper.nextPage(context, RequestServiceFlow());
                }),
            BottomSheetAction(
                title: const Text('WASILISHA & CHAPA TIKETI'),
                onPressed: (context) async {
                  await submit(true);
                  Helper.nextPage(context, RequestServiceFlow());
                }),
          ],
          cancelAction: CancelAction(title: const Text('SITISHA')),
        );
      },
      steps: bookingSteps,
      config: CoolStepperConfig(
          headerColor: Colors.redAccent,
          icon: null,
          iconColor: Colors.white70,
          backText: 'RUDI NYUMA',
          nextText: 'ENDELEA MBELE',
          finalText: 'WASILISHA TIKETI',
          titleTextStyle: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          subtitleTextStyle: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          )),
    );
  }

  Widget _stepOne(form) {
    return Column(children: [
      Container(
          height: 280,
          child: SfDateRangePicker(
              todayHighlightColor: Colors.redAccent,
              monthViewSettings:
                  DateRangePickerMonthViewSettings(viewHeaderHeight: 20),
              monthCellStyle: DateRangePickerMonthCellStyle(
                  todayTextStyle: TextStyle(color: Colors.redAccent)),
              initialSelectedDate: DateTime.now(),
              showActionButtons: false,
              selectionColor: Colors.redAccent,
              rangeSelectionColor: Colors.redAccent,
              enablePastDates: false,
              showNavigationArrow: true,
              controller: _rangePickerController,
              onSelectionChanged: (date) async {
                if (date.value is DateTime) {
                  setState(() {
                    _travelDate.text = DateFormat('yyyy-MM-dd')
                        .format(_rangePickerController.selectedDate);
                  });
                  await fetchSchedules();
                }
              })),
      Divider(height: 0),
      choices != null
          ? SmartSelect.single(
              placeholder: 'Chagua safari ya abiria',
              title: 'CHAGUA SAFARI',
              //selectedValue: _os,
              choiceItems: choices,
              choiceDivider: true,
              onChange: (selected) async {
                setState(() {
                  _route = TextEditingController(text: selected.value);
                });

                await fetchSchedules();
              },
              // modalType: S2ModalType.bottomSheet,
              tileBuilder: (context, state) {
                return S2Tile.fromState(
                  state,
                  enabled: choices != null,
                  isLoading: choices == null,
                  isTwoLine: true,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  leading:
                      const Icon(Icons.map, size: 40, color: Colors.redAccent),
                );
              },
              value: _route.text,
            )
          : SizedBox(),
      Divider(height: 0),
      schedules != null
          ? SmartSelect.single(
              placeholder: 'Chagua ratiba ya basi',
              title: 'RATIBA YA BASI',
              choiceItems: schedules,
              onChange: (selected) async {
                ScheduleModel _currentSchedule = scheduleResponse.firstWhere(
                    (element) => element.scheduleNo == selected.value);
                List<S2Choice<String>> _boardingPoints;
                List<S2Choice<String>> _droppingPoints;
                if (_currentSchedule.boardingPoints != null) {
                  _boardingPoints = _currentSchedule.boardingPoints
                      .map((item) =>
                          S2Choice<String>(value: item.id, title: item.name))
                      .toList();
                }
                if (_currentSchedule.droppingPoints != null) {
                  _droppingPoints = _currentSchedule.droppingPoints
                      .map((item) =>
                          S2Choice<String>(value: item.id, title: item.name))
                      .toList();
                }
                setState(() {
                  _schedule = TextEditingController(text: selected.value);
                  selectedSeats = [];
                  boardingPoints = _boardingPoints;
                  droppingPoints = _droppingPoints;
                  selectedSchedule = _currentSchedule;
                });
              },
              // modalType: S2ModalType.bottomSheet,
              tileBuilder: (context, state) {
                return S2Tile.fromState(
                  state,
                  isTwoLine: true,
                  isLoading: scheduleIsLoading,
                  loadingText: 'Inatafuta ratiba ..',
                  enabled: scheduleIsEnabled,
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                  leading: const Icon(Icons.timer,
                      size: 40, color: Colors.redAccent),
                );
              },
              value: selectedSchedule?.scheduleNo,
            )
          : SizedBox(height: 0),
    ]);
  }

  Widget _renderBusSeats(ScheduleModel selectedSchedule) {
    List tableData = [];
    for (final seatRow in selectedSchedule.seatChart) {
      List rowData = [];
      for (final seat in seatRow.values.toList()) {
        rowData.add(seat.toString() == '_' ? '' : seat);
      }
      tableData.add(rowData);
    }

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 60),
        height: 650,
        width: 450,
        child: ListView.builder(
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: tableData.length,
          itemBuilder: (BuildContext context, int index) {
            List tableRowData = tableData[index];
            return GridView.count(
              physics: ClampingScrollPhysics(),
              crossAxisSpacing: 5,
              shrinkWrap: true,
              crossAxisCount: tableRowData.length,
              children: List.generate(tableRowData.length, (i) {
                return renderSeat(tableRowData[i], i);
              }),
            );
          },
        ));
  }

  getSeatStatus(label) {
    if (selectedSeats != null && selectedSeats.contains(label)) {
      return 'selected';
    }
    if (selectedSchedule.availableSeats.contains(label)) {
      return 'available';
    } else if (selectedSchedule.unavailableSeats.contains(label)) {
      return 'unavailable';
    }
  }

  handleSeatClick(label, status) {
    String status = getSeatStatus(label);
    switch (status) {
      case 'available':
        if (selectedSeats.length == selectedSchedule.totalAvailableSeats) {
          Fluttertoast.showToast(
            msg: 'Maximum number of ' +
                selectedSchedule.totalAvailableSeats.toString() +
                ' seats reached',
            backgroundColor: Colors.red,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
          );
          return;
        }
        selectedSeats.add(label);
        setState(() {
          selectedSeats = selectedSeats;
        });
        break;
      case 'unavailable':
        break;
      case 'selected':
        setState(() {
          selectedSeats = selectedSeats.where((e) {
            return e != label;
          }).toList();
          if (passengers != null) {
            passengers =
                passengers.where((element) => element.seatNo != label).toList();
          }
        });
        break;
    }
  }

  renderSeat(label, index) {
    double seatHeightWeight = 35;
    double seatFontSize = 13;

    if (label.toString() == '') {
      return Container(
          height: seatHeightWeight,
          width: seatHeightWeight,
          child: Center(
              child: Text(label.toString(),
                  style: TextStyle(
                      fontSize: seatFontSize, fontWeight: FontWeight.w600))));
    } else {
      String status = getSeatStatus(label);

      switch (status) {
        case 'available':
          return InkWell(
              onTap: () => handleSeatClick(label, 'selected'),
              child: Container(
                  height: seatHeightWeight,
                  width: seatHeightWeight,
                  child: Center(
                      child: Text(label.toString(),
                          style: TextStyle(
                              fontSize: seatFontSize,
                              fontWeight: FontWeight.w500))),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/seat-available.png"),
                    fit: BoxFit.cover,
                  ))));

        case 'selected':
          return InkWell(
              onTap: () => handleSeatClick(label, 'available'),
              child: Container(
                  height: seatHeightWeight,
                  width: seatHeightWeight,
                  child: Center(
                      child: Text(label.toString(),
                          style: TextStyle(
                              fontSize: seatFontSize,
                              fontWeight: FontWeight.w500))),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/seat-selected.png"),
                    fit: BoxFit.cover,
                  ))));

        case 'unavailable':
          return InkWell(
              onTap: () => handleSeatClick(label, 'unavailable'),
              child: Container(
                  height: seatHeightWeight,
                  width: seatHeightWeight,
                  child: Center(
                      child: Text(label.toString(),
                          style: TextStyle(
                              fontSize: seatFontSize,
                              fontWeight: FontWeight.w500))),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/seat-booked.png"),
                    fit: BoxFit.cover,
                  ))));
      }
    }
  }

  renderPassengerFields() {
    if (selectedSeats.length > 0) {
      return ListView.builder(
          physics: ClampingScrollPhysics(),
          shrinkWrap: true,
          itemCount: selectedSeats.length,
          itemBuilder: (BuildContext context, int index) {
            return passengerField(selectedSeats[index]);
          });
    }

    return SizedBox(height: 10);
  }

  Widget passengerField(seat) {
    PassengerModel passenger;
    if (passengers.isNotEmpty &&
        passengers.where((e) => e.seatNo == seat).isNotEmpty) {
      passenger = passengers.firstWhere((e) => e.seatNo == seat);
    }

    return Card(
      margin: EdgeInsets.only(bottom: 20),
      elevation: 3,
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: droppingPoints != null ? 380 : 280,
        child: Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 45,
                      child: ListTile(
                        dense: true,
                        tileColor: Colors.grey,
                        title: Text("SITI - " + seat.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300))),
                    ),
                    Container(
                        padding:
                            EdgeInsets.only(left: 15, right: 15, bottom: 0),
                        child: Column(children: [
                          Container(
                            child: TextFormField(
                                initialValue: passenger?.fullName,
                                onChanged: (value) =>
                                    updatePassenger(seat, value, 'name'),
                                decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    labelText: 'Jina la abiria'),
                                validator: (value) {
                                  RegExp regex = new RegExp(
                                      r'(?=^.{0,40}$)^[a-zA-Z]+\s[a-zA-Z]+$');
                                  if (value.isEmpty || !regex.hasMatch(value)) {
                                    return 'Tafadhali jaza jina zima la abiria';
                                  }
                                  return null;
                                }),
                          ),
                          Container(
                            child: TextFormField(
                                initialValue: passenger?.phoneNumber,
                                //controller: _phoneName,
                                onChanged: (value) =>
                                    updatePassenger(seat, value, 'phone'),
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                    enabledBorder: InputBorder.none,
                                    labelText: 'Namba ya simu'),
                                validator: (value) => value.isEmpty
                                    ? 'Tafadhali jaza namba sahihi ya simu'
                                    : null),
                          ),
                        ])),
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(children: [
                          boardingPoints != null
                              ? SmartSelect.single(
                                  placeholder: 'Chagua kituo cha kupanda basi',
                                  title: 'Kituo cha kupanda',
                                  value: passenger != null
                                      ? passenger.boardingPoint?.id
                                      : null,
                                  choiceItems: boardingPoints,
                                  onChange: (selected) async {
                                    BoardingModel point = selectedSchedule
                                        .boardingPoints
                                        .firstWhere((element) =>
                                            element.id == selected.value);
                                    updatePassenger(
                                        seat, point, 'boarding_point');
                                  },
                                  modalType: S2ModalType.bottomSheet,
                                  tileBuilder: (context, state) {
                                    return S2Tile.fromState(
                                      state,
                                      isTwoLine: true,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 0),
                                    );
                                  },
                                )
                              : SizedBox(),
                          droppingPoints != null
                              ? SmartSelect.single(
                                  placeholder: 'Chagua kituo cha kushukia',
                                  title: 'Kituo cha kushukia',
                                  value: passenger != null
                                      ? passenger.droppingPoint?.id
                                      : null,
                                  choiceItems: droppingPoints,
                                  onChange: (selected) async {
                                    BoardingModel point = selectedSchedule
                                        .droppingPoints
                                        .firstWhere((element) =>
                                            element.id == selected.value);
                                    updatePassenger(
                                        seat, point, 'dropping_point');
                                  },
                                  modalType: S2ModalType.bottomSheet,
                                  tileBuilder: (context, state) {
                                    return S2Tile.fromState(
                                      state,
                                      isTwoLine: true,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 0),
                                    );
                                  },
                                )
                              : SizedBox(),
                        ])),
                  ],
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    );
  }

  updatePassenger(seat, value, field) {
    PassengerModel passenger;
    if (passengers.isNotEmpty &&
        passengers.where((e) => e.seatNo == seat).isNotEmpty) {
      passenger = passengers.firstWhere((e) => e.seatNo == seat);
    }

    switch (field) {
      case 'name':
        passenger = PassengerModel(
            seatNo: seat,
            fullName: value,
            phoneNumber: passenger?.phoneNumber,
            boardingPoint: passenger?.boardingPoint,
            droppingPoint: passenger?.droppingPoint);

        break;
      case 'phone':
        passenger = PassengerModel(
            seatNo: seat,
            fullName: passenger?.fullName,
            phoneNumber: value,
            boardingPoint: passenger?.boardingPoint,
            droppingPoint: passenger?.droppingPoint);
        break;
      case 'boarding_point':
        passenger = PassengerModel(
            seatNo: seat,
            fullName: passenger?.fullName,
            phoneNumber: passenger?.phoneNumber,
            boardingPoint: value,
            droppingPoint: passenger?.droppingPoint);
        break;
      case 'dropping_point':
        passenger = PassengerModel(
            seatNo: seat,
            fullName: passenger?.fullName,
            phoneNumber: passenger?.phoneNumber,
            boardingPoint: passenger?.boardingPoint,
            droppingPoint: value);
        break;
      default:
        passenger = PassengerModel(
            seatNo: seat,
            fullName: passenger?.fullName,
            phoneNumber: passenger?.phoneNumber,
            boardingPoint: passenger?.boardingPoint,
            droppingPoint: value);
        break;
    }

    this.setState(() {
      passengers.removeWhere((element) => element.seatNo == seat);
      passengers
          .removeWhere((element) => !selectedSeats.contains(element.seatNo));
      passengers.add(passenger);
    });
  }

  Widget renderConfirmScreen() {
    return Column(
      children: <Widget>[
        Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Card(
              elevation: 2,
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 58,
                              child: ListTile(
                                  dense: true,
                                  tileColor: Colors.grey,
                                  trailing: Icon(Icons.cloud_done,
                                      color: Colors.teal.shade700),
                                  title: Text("Taarifa za Safari",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)),
                                  subtitle:
                                      Text('Taarifa za safari ya abiria')),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300))),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 5),
                              child: ListTile(
                                title: Text(
                                    selectedSchedule != null
                                        ? selectedSchedule?.date
                                        : '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        selectedRoute != null
                                            ? selectedRoute.name
                                            : '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18)),
                                    SizedBox(height: 10),
                                    Text(
                                        selectedSchedule != null
                                            ? selectedSchedule?.name
                                            : '',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      flex: 1,
                    ),
                  ],
                ),
              ),
            )),
        Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Card(
              elevation: 2,
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 60,
                              child: ListTile(
                                dense: true,
                                trailing: Icon(Icons.cloud_done,
                                    color: Colors.teal.shade700),
                                tileColor: Colors.grey,
                                title: Text('Taarifa za Abiria',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                subtitle: Text('Jumla ya siti ' +
                                    (passengers.length.toString() ?? '0') +
                                    ' za abiria'),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300))),
                            ),
                            Container(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: passengers
                                      .map((passenger) => Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors
                                                          .grey.shade300))),
                                          child: ListTile(
                                              horizontalTitleGap: 5,
                                              dense: true,
                                              subtitle: passenger
                                                          .boardingPoint !=
                                                      null
                                                  ? Text(
                                                      passenger
                                                          .boardingPoint.name,
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    )
                                                  : Text(
                                                      'Hakuna kituo cha kupandia',
                                                      style: TextStyle(
                                                          fontSize: 14)),
                                              minVerticalPadding: 0,
                                              title: Text(
                                                  passenger.seatNo +
                                                      ' - ' +
                                                      (passenger?.fullName ??
                                                          '') +
                                                      ' - ' +
                                                      (passenger?.phoneNumber ??
                                                          ''),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black54,
                                                      fontSize: 16)))))
                                      .toList()),
                            ),
                          ],
                        ),
                      ),
                      flex: 1,
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Future submit(bool printTicket) async {
    EasyLoading.show(status: 'Inawasilisha...', dismissOnTap: true);
    setState(() {
      isSubmitting = true;
    });
    dynamic response =
        await Api.createBooking(selectedSchedule, passengers, selectedMethod);
    if (response is List<BookingModel>) {
      if (printTicket) {
        response.forEach((e) async {
          EasyLoading.show(status: 'Printing tiketi');
          await Functions.printTicket(context, e.ticketNo).whenComplete(() {
            setState(() {
              isSubmitting = false;
            });
            Helper.nextPage(context, RequestServiceFlow());
          });
          EasyLoading.dismiss();
        });
      } else {
        Helper.nextPage(context, RequestServiceFlow());
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Tafadhali, hakiki kamma tiketi imerudi',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      EasyLoading.dismiss();
    }
  }
}
