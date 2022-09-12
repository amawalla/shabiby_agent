// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'dart:convert';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import '../../widgets/dialog_prompt.dart';
import 'package:provider/provider.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/models/setting_provider.dart';
import 'package:repair_service_ui/pages/booking/wizard.dart';
import 'package:repair_service_ui/pages/request_service_flow.dart';
import 'package:repair_service_ui/pages/setting/bluetooth/bluetooth.dart';
import 'package:repair_service_ui/utils/functions.dart';
import 'package:repair_service_ui/utils/helper.dart';
import 'package:repair_service_ui/utils/session.dart';
import 'package:repair_service_ui/widgets/red_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletons/skeletons.dart';
import 'package:smart_select/smart_select.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:repair_service_ui/actions/api.dart';

import '../setting/bluetooth/print_helper.dart';
import 'booking.dart';

class BookingCreate extends StatefulWidget {
  final Function nextPage;
  final Function prevPage;

  BookingCreate({this.nextPage, this.prevPage});

  @override
  _BookingCreateState createState() => _BookingCreateState();
}

class _BookingCreateState extends State<BookingCreate> {
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
  String routeName;
  String pageTitle = 'KATA TIKETI';
  List<ScheduleModel> scheduleResponse;
  List<BookingModel> bookings = [];
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
  final formatCurrency = new NumberFormat.currency(
      locale: "en_US", symbol: "TSh ", decimalDigits: 0);

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
              .where((element) => element.isAvailable)
              .map((item) =>
                  S2Choice<String>(value: item.scheduleNo, title: item.name))
              .toList();
          scheduleIsEnabled = true;
          scheduleIsLoading = false;
          selectedSchedule = null;
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
        routeName = selectedRoute != null ? selectedRoute.name : ' ';
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
      return Scaffold(
          appBar: AppBar(
            title: Text(
              pageTitle,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
            automaticallyImplyLeading: true,
            brightness: Brightness.light,
            elevation: 4.0,
            backgroundColor: Colors.redAccent,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            actions: [
              box.read('is_printer') == false
                  ? InkWell(
                      onTap: () =>
                          Functions.pushPage(context, BluetoothSetting()),
                      child: Padding(
                          padding: EdgeInsets.all(12),
                          child: box.read('bluetooth_device_connected') != null
                              ? Icon(
                                  Icons.bluetooth_connected_rounded,
                                  color: Colors.white70,
                                  size: 28,
                                )
                              : Icon(
                                  Icons.bluetooth_disabled,
                                  color: Colors.white70,
                                  size: 28,
                                )),
                    )
                  : SizedBox()
            ],
          ),
          backgroundColor: Colors.white,
          body: LoadingOverlay(
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
              )));
    });
  }

  buildStepWizard(BuildContext context) {
    final bookingSteps = [
      WizardStep(
          title: 'Taarifa ya Safari',
          subtitle: 'Jaza safari, tarehe na mda wa kuondoka',
          content: Form(
            key: _formKey,
            child: _stepOne(_formKey),
          ),
          validation: () {
            if (_schedule.text.isEmpty) {
              Fluttertoast.showToast(
                msg: 'Tafadhali chagua ratiba ya basi',
                backgroundColor: Colors.brown.shade900,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_LONG,
              );
              return 'Tafadhali jaza taarifa zote zinazohitaji';
            }
            setState(() {
              pageTitle = 'CHAGUA SITI';
            });
            return null;
          },
          onBack: () {
            setState(() {
              pageTitle = 'TIKETI ZA ABIRIA';
            });
          }),
      WizardStep(
          title: selectedSchedule?.route,
          subtitle: selectedSchedule?.name,
          content: SingleChildScrollView(
            child: selectedSchedule != null
                ? _renderBusSeats(selectedSchedule)
                : SizedBox(height: 60),
          ),
          validation: () {
            if (selectedSeats.isEmpty) {
              Fluttertoast.showToast(
                msg: 'Tafadhali chagua siti/viti kuendelea',
                backgroundColor: Colors.brown.shade900,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_LONG,
              );
              return 'Tafadhali chagua siti/viti kuendelea';
            }
            setState(() {
              pageTitle = 'TAARIFA ZA ABIRIA';
            });
            return null;
          },
          onBack: () {
            setState(() {
              pageTitle = 'KATA TIKETI';
            });
          }),
      WizardStep(
          title: selectedSchedule?.route,
          subtitle: 'Jaza taarifa muhimu za abiria ' +
              (selectedSeats != null ? selectedSeats.length.toString() : '0'),
          content: Form(
              key: _passengerFormKey,
              child: Column(children: [
                renderPassengerFields(),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: ' ---- '),
                        TextSpan(text: 'Mwisho'),
                        TextSpan(text: ' ---- '),
                      ],
                    ),
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                SizedBox(height: 20)
              ])),
          validation: () {
            if (!_passengerFormKey.currentState.validate()) {
              Fluttertoast.showToast(
                msg: 'Tafadhali jaza taarifa za abiria',
                backgroundColor: Colors.brown.shade900,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_LONG,
              );
              return 'Tafadhali jaza taarifa za abiri';
            }
            setState(() {
              pageTitle = 'WASILISHA TAARIFA';
            });
            return null;
          },
          onBack: () {
            setState(() {
              pageTitle = 'CHAGUA SITI';
            });
          }),
      WizardStep(
          title: 'HAKIKI TAARIFA',
          subtitle: 'Hakiki taarifa kisha bonyeza WASILISHA TAARIFA',
          content: renderConfirmScreen(),
          validation: () {
            if (bookings.isEmpty) {
              Fluttertoast.showToast(
                msg: 'Tafadhali wasilisha kwanza kabla ya kuchapa tiketi mbele',
                backgroundColor: Colors.brown.shade900,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_LONG,
              );
              return 'Tafadhali chagua aina ya malipo';
            }
            setState(() {
              pageTitle = 'TIKETI ZA ABIRIA';
            });
            return null;
          },
          onBack: () {
            setState(() {
              pageTitle = 'TAARIFA ZA ABIRIA';
            });
          }),
      WizardStep(
          title: 'TIKETI ZA ABIRIA',
          subtitle: 'Maliza kwa kuchapa tiketi za abiria au kurudi mwanzo',
          content: renderBookings(context),
          validation: () {
            if (selectedMethod.isEmpty) {
              Fluttertoast.showToast(
                msg: 'Tafadhali chagua aina ya malipo',
                backgroundColor: Colors.brown.shade700,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_LONG,
              );
              return 'Tafadhali chagua aina ya malipo';
            }
            return null;
          },
          onBack: () {
            setState(() {
              pageTitle = 'WASILISHA TAARIFA';
            });
          }),
    ];
    return BookingWizard(
      showErrorSnackbar: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      steps: bookingSteps,
      onCompleted: () {
        showAdaptiveActionSheet(
          context: context,
          title: Text(' TIKETI'),
          androidBorderRadius: 30,
          isDismissible: true,
          actions: <BottomSheetAction>[
            BottomSheetAction(
                title: const Text('CHAPA TIKETI ZOTE'),
                onPressed: (context) async {
                  if (bookings.isNotEmpty) {
                    await Functions.batchPrintBookings(context, bookings);
                  }
                }),
            BottomSheetAction(
                title: const Text('WEKA TIKETI NYINGINE'),
                onPressed: (context) {
                  return Functions.pushPageReplacementUntil(
                      context, BookingCreate());
                }),
          ],
          cancelAction: CancelAction(
              title: const Text(
                'RUDI MWANZO',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: (e) => Helper.nextPage(context, RequestServiceFlow())),
        );
      },
      config: CoolStepperConfig(
          headerColor: Colors.redAccent,
          icon: null,
          iconColor: Colors.white70,
          backText: 'RUDI NYUMA',
          nextText: 'ENDELEA MBELE ',
          nextTextList: [
            'CHAGUA SITI',
            'ABIRIA',
            'HAKIKI TAARIFA',
            'CHAPA TIKETI'
          ],
          backTextList: [
            'BADILI SAFARI',
            'BADILI SITI',
            'ABIRIA',
            'CHAPA TIKETI'
          ],
          finalText: 'CHAPA TIKETI ',
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
          margin: EdgeInsets.only(top: 10),
          child: SfDateRangePicker(
              todayHighlightColor: Colors.redAccent,
              monthViewSettings:
                  DateRangePickerMonthViewSettings(viewHeaderHeight: 40),
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
              modalFilter: true,
              choiceDivider: true,
              onChange: (selected) async {
                setState(() {
                  _route = TextEditingController(text: selected.value);
                  routeName = selected.valueDisplay;
                  selectedRoute = routes != null
                      ? routes.firstWhere(
                          (element) => element.id == selected.value,
                          orElse: () => null)
                      : null;
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

              choiceEmptyBuilder: (context, value) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_off_outlined,
                      size: 100,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(height: 10),
                    Text('Hakuna safari imepatikana',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ));
              },
            )
          : SizedBox(),
      Divider(height: 0),
      schedules != null
          ? SmartSelect.single(
              choiceDivider: true,
              choiceEmptyBuilder: (context, value) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bus_alert,
                      size: 100,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(height: 10),
                    Text('Hakuna ratiba imepatikana',
                        style: TextStyle(fontSize: 14, color: Colors.grey)),
                    SizedBox(height: 5),
                    Text('Unaweza badili tarehe au safari kutafuta',
                        style: TextStyle(fontSize: 14, color: Colors.grey))
                  ],
                ));
              },
              placeholder: 'Chagua ratiba ya basi',
              title: 'RATIBA YA BASI',
              choiceItems: schedules,
              onChange: (selected) async {
                print('Element is');
                print(selected);

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

                print(selectedSchedule?.subRoutes);
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

    return Center(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 60),
            margin: EdgeInsets.symmetric(vertical: 20),
            height: 800,
            width: 400,
            child: ListView.builder(
              physics: ClampingScrollPhysics(),
              shrinkWrap: false,
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
            )));
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
    double seatHeightWeight = selectedSchedule.seatLayout == '2-2' ? 35 : 25;
    double seatFontSize = 16;

    if (label.toString() == '') {
      return Container(
          height: seatHeightWeight,
          width: seatHeightWeight,
          child: Center(
              child: Text(label.toString(),
                  style: TextStyle(
                      fontSize: seatFontSize, fontWeight: FontWeight.w700))));
    } else {
      String status = getSeatStatus(label);

      switch (status) {
        case 'available':
          return InkWell(
              onTap: () => handleSeatClick(label, 'selected'),
              child: Container(
                  height: seatHeightWeight,
                  width: seatHeightWeight,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Center(
                      child: Text(label.toString(),
                          style: TextStyle(
                              fontSize: seatFontSize,
                              fontWeight: FontWeight.w600))),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    opacity: 0.8,
                    image: AssetImage("assets/images/grey-seat.png"),
                    fit: BoxFit.cover,
                  ))));

        case 'selected':
          return InkWell(
              onTap: () => handleSeatClick(label, 'available'),
              child: Container(
                  height: seatHeightWeight,
                  width: seatHeightWeight,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Center(
                      child: Text(label.toString(),
                          style: TextStyle(
                              fontSize: seatFontSize,
                              color: Colors.white,
                              fontWeight: FontWeight.w600))),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/red-seat.png"),
                    fit: BoxFit.cover,
                  ))));

        case 'unavailable':
          return InkWell(
              onTap: () => handleSeatClick(label, 'unavailable'),
              child: Container(
                  height: seatHeightWeight,
                  width: seatHeightWeight,
                  padding: EdgeInsets.only(bottom: 10),
                  child: Center(
                      child: Text(label.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: seatFontSize,
                              fontWeight: FontWeight.w600))),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/green-seat.png"),
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
      margin: EdgeInsets.only(bottom: 0),
      elevation: 0,
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
                        trailing: InkWell(
                            onTap: () async {
                              dynamic customAmount = await prompt(
                                context,
                                title: const Text(
                                  'Ungependa badili nauli ?',
                                  textAlign: TextAlign.center,
                                ),
                                dialogPadding:
                                    EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 14.0),
                                initialValue: passenger != null
                                    ? passenger.amount.toString()
                                    : selectedSchedule.fare,
                                isSelectedInitialValue: false,
                                textOK: const Text('Sawa'),
                                textCancel: const Text('Hapana'),
                                hintText: 'Tafadhali andika nauli',
                                hintStyle: TextStyle(fontSize: 18),
                                inputStyle: TextStyle(fontSize: 30),
                                validator: (String value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Tafadhali weka nauli au bonyeza hapana';
                                  } else if (int.parse(value) <= 1000) {
                                    return 'Tafadhali weka nauli sahihi kuendelea';
                                  } else if (int.parse(value) >
                                      int.parse(selectedSchedule.fare)) {
                                    return 'Nauli haiwezi kuwa kubwa kuliko TSh ' +
                                        selectedSchedule.fare +
                                        '/=';
                                  }
                                  return null;
                                },
                                minLines: 1,
                                maxLines: 1,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                autoFocus: true,
                                obscureText: false,
                                obscuringCharacter: '*',
                                showPasswordIcon: false,
                                barrierDismissible: true,
                                textCapitalization: TextCapitalization.words,
                                textAlign: TextAlign.center,
                              );

                              if (customAmount != null) {
                                print('Updating passenger fare to ' +
                                    customAmount.toString());
                                updatePassenger(seat, customAmount, 'amount');
                              }
                            },
                            child: Text(
                              passenger?.amount != null
                                  ? formatCurrency.format(passenger.amount)
                                  : formatCurrency.format(
                                          int.parse(selectedSchedule.fare)) +
                                      '/=',
                              style: TextStyle(fontSize: 17),
                            )),
                        tileColor: Colors.grey,
                        title: Text("SITI - " + seat.toString(),
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          border: Border(
                              bottom: BorderSide(color: Colors.grey.shade400))),
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
                                  if (value.isEmpty ||
                                      !regex.hasMatch(value.trim())) {
                                    return 'Tafadhali jaza jina zima la abiria';
                                  }
                                  return null;
                                }),
                          ),
                          Container(
                            child: TextFormField(
                                initialValue: passenger?.phoneNumber,
                                // controller: _phoneNumber ?? '',
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
                              ? FormField(validator: (value) {
                                  return value != true &&
                                          selectedSchedule.isEnRoute
                                      ? 'Tafadhali jaza kituo cha kupandia '
                                      : null;
                                }, builder:
                                  (FormFieldState<bool> boardingPointState) {
                                  return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            height: 60,
                                            child: SmartSelect.single(
                                              placeholder:
                                                  'Chagua kituo cha kupanda basi',
                                              title: 'Kituo cha kupanda',
                                              value: passenger != null
                                                  ? passenger.boardingPoint?.id
                                                  : null,
                                              choiceItems: boardingPoints,
                                              onChange: (selected) async {
                                                boardingPointState
                                                    .setValue(true);
                                                BoardingModel point =
                                                    selectedSchedule
                                                        .boardingPoints
                                                        .firstWhere((element) =>
                                                            element.id ==
                                                            selected.value);
                                                updatePassenger(seat, point,
                                                    'boarding_point');
                                              },
                                              modalType:
                                                  S2ModalType.bottomSheet,
                                              tileBuilder: (context, state) {
                                                return S2Tile.fromState(
                                                  state,
                                                  isTwoLine: true,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 0,
                                                      vertical: 0),
                                                );
                                              },
                                            )),
                                        boardingPointState.hasError
                                            ? Text(
                                                boardingPointState.errorText,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red),
                                              )
                                            : Container(),
                                      ]);
                                })
                              : SizedBox(),
                          droppingPoints != null
                              ? FormField(validator: (value) {
                                  return value != true &&
                                          selectedSchedule.isEnRoute
                                      ? 'Tafadhali jaza kituo cha kushukia '
                                      : null;
                                }, builder:
                                  (FormFieldState<bool> droppingPointState) {
                                  return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                            height: 60,
                                            child: SmartSelect.single(
                                              placeholder:
                                                  'Chagua kituo cha kushukia',
                                              title: 'Kituo cha kushukia',
                                              value: passenger != null
                                                  ? passenger.droppingPoint?.id
                                                  : null,
                                              choiceItems: droppingPoints,
                                              onChange: (selected) async {
                                                droppingPointState
                                                    .setValue(true);
                                                BoardingModel point =
                                                    selectedSchedule
                                                        .droppingPoints
                                                        .firstWhere((element) =>
                                                            element.id ==
                                                            selected.value);
                                                updatePassenger(seat, point,
                                                    'dropping_point');
                                              },
                                              modalType:
                                                  S2ModalType.bottomSheet,
                                              tileBuilder: (context, state) {
                                                return S2Tile.fromState(
                                                  state,
                                                  isTwoLine: true,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 0,
                                                      vertical: 0),
                                                );
                                              },
                                            )),
                                        droppingPointState.hasError
                                            ? Text(
                                                droppingPointState.errorText,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.red),
                                              )
                                            : Container(),
                                      ]);
                                })
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
            fullName: value.toString().trim(),
            phoneNumber: passenger?.phoneNumber,
            boardingPoint: passenger?.boardingPoint,
            amount: passenger != null
                ? passenger.amount
                : int.parse(selectedSchedule.fare),
            droppingPoint: passenger?.droppingPoint);

        break;
      case 'phone':
        passenger = PassengerModel(
            seatNo: seat,
            fullName: passenger?.fullName,
            phoneNumber: value.toString().trim(),
            boardingPoint: passenger?.boardingPoint,
            amount: passenger != null
                ? passenger.amount
                : int.parse(selectedSchedule.fare),
            droppingPoint: passenger?.droppingPoint);
        break;
      case 'boarding_point':
        print(value);
        passenger = PassengerModel(
            seatNo: seat,
            fullName: passenger?.fullName,
            phoneNumber: passenger?.phoneNumber,
            boardingPoint: value,
            amount: passenger != null
                ? passenger.amount
                : int.parse(selectedSchedule.fare),
            droppingPoint: passenger?.droppingPoint);
        break;
      case 'dropping_point':
        print(value);
        passenger = PassengerModel(
            seatNo: seat,
            fullName: passenger?.fullName,
            phoneNumber: passenger?.phoneNumber,
            boardingPoint: passenger?.boardingPoint,
            amount: passenger != null
                ? passenger.amount
                : int.parse(selectedSchedule.fare),
            droppingPoint: value);
        break;
      case 'amount':
        passenger = PassengerModel(
            seatNo: seat,
            fullName: passenger?.fullName,
            phoneNumber: passenger?.phoneNumber,
            boardingPoint: passenger?.boardingPoint,
            amount: int.parse(value),
            droppingPoint: passenger?.droppingPoint);

        break;
    }

    if (field != 'amount') {
      if (selectedSchedule.subRoutes != null &&
          passenger.boardingPoint != null &&
          passenger.droppingPoint != null) {
        SubRouteModel subRoute = selectedSchedule.subRoutes.firstWhere(
            (element) =>
                element.point ==
                passenger.boardingPoint.id + '-' + passenger.droppingPoint.id,
            orElse: () => null);

        if (subRoute != null) {
          print(subRoute.toJson());
          print(subRoute);
          passenger = PassengerModel(
              seatNo: seat,
              fullName: passenger?.fullName,
              phoneNumber: passenger?.phoneNumber,
              boardingPoint: passenger?.boardingPoint,
              droppingPoint: passenger?.droppingPoint,
              amount: subRoute.amount,
              subRoute: subRoute);
        }
      }
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
            margin: EdgeInsets.only(bottom: 0),
            child: Card(
              margin: EdgeInsets.all(0.0),
              elevation: 2,
              child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: 150,
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
                                      color: bookings.isNotEmpty
                                          ? Colors.teal.shade700
                                          : Colors.black38),
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
                                    Text(routeName ?? ' ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18)),
                                    SizedBox(height: 5),
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
            margin: EdgeInsets.only(bottom: 0),
            child: Card(
              elevation: 2,
              margin: EdgeInsets.all(0.0),
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
                                    color: bookings.isNotEmpty
                                        ? Colors.teal.shade700
                                        : Colors.black38),
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
                                              subtitle: Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                        text: formatCurrency
                                                                .format(
                                                                    passenger
                                                                        .amount)
                                                                .toString() +
                                                            '/=',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    TextSpan(
                                                        text: passenger
                                                                    .boardingPoint !=
                                                                null
                                                            ? ' | '
                                                            : ' '),
                                                    TextSpan(
                                                        text: passenger
                                                            .boardingPoint
                                                            ?.name),
                                                    TextSpan(
                                                      text: passenger
                                                                  .droppingPoint !=
                                                              null
                                                          ? ' - '
                                                          : ' ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    TextSpan(
                                                        text: passenger
                                                            .droppingPoint
                                                            ?.name),
                                                  ],
                                                ),
                                              ),
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
        SizedBox(height: 20),
        bookings.isEmpty
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: SizedBox(
                    height: 60,
                    child: RedButton(
                      isLoading: isSubmitting,
                      text: 'Wasilisha Taarifa'.toUpperCase(),
                      onPressed: () async {
                        await submit(false);
                      },
                    )))
            : SizedBox()
      ],
    );
  }

  Widget renderBookings(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.only(top: 5),
      child: Skeleton(
        skeleton: SkeletonListView(),
        isLoading: isSubmitting,
        child: ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(height: 3, color: Colors.grey),
            physics: ClampingScrollPhysics(),
            itemCount: bookings != null ? bookings.length : 1,
            itemBuilder: (context, index) {
              BookingModel booking = bookings[index];
              return Container(
                decoration: BoxDecoration(color: Colors.white),
                child: ListTile(
                  selectedColor: Colors.black,
                  leading: FittedBox(
                      child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: booking.statusColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          spreadRadius: 0,
                          blurRadius: 1,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Center(
                        child: Text(
                      booking.seatNo,
                      style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    )),
                  )),
                  dense: true,
                  enableFeedback: true,
                  title: Text(
                    booking.name,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87.withOpacity(0.8)),
                  ),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          booking.ticketNo,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: 'TSh ' + booking.totalAmount + '/=',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: booking?.boardingPoint != null
                                      ? ' | '
                                      : ' '),
                              TextSpan(text: booking?.boardingPoint ?? ' '),
                            ],
                          ),
                          style: TextStyle(fontSize: 14),
                        )
                      ]),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.status ?? ''),
                      SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                  onTap: () {
                    return showSingleItemMenu(context, booking);
                  },
                ),
              );
            }),
      ),
    );
  }

  showSingleItemMenu(BuildContext context, BookingModel booking) {
    return showAdaptiveActionSheet(
      context: context,
      title: Column(
        children: [
          Text(booking.name + ' - ' + booking.seatNo,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
          SizedBox(height: 10),
          Text(booking.ticketNo,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          SizedBox(height: 5),
          Text(booking.statusLabel),
          SizedBox(height: 5),
          Text('Imetolewa na: ' + (booking.issuedBy ?? ' Self Booking')),
          SizedBox(height: 5),
          Text('Imetengenezwa tarehe: ' + booking.createdAt),
          SizedBox(height: 5),
          Divider(color: Colors.black54)
        ],
      ),
      androidBorderRadius: 30,
      isDismissible: true,
      actions: <BottomSheetAction>[
        BottomSheetAction(
            title: const Text('Onesha Ticket'),
            onPressed: (context) async {
              await Functions.pushPage(context, BookingShow(booking: booking));
            }),
        BottomSheetAction(
            title: const Text('Chapa Tiketi'),
            onPressed: (context) async {
              EasyLoading.show(
                  status: 'Printing Tiketi ' + booking.ticketNo.toString(),
                  dismissOnTap: true);

              await Functions.printTicket(context, booking.ticketNo)
                  .then((value) {
                EasyLoading.dismiss();
              });
            }),
        BottomSheetAction(
            title: const Text('Tuma / Share'),
            onPressed: (context) async {
              await Share.share(
                  booking.name +
                      ' https://shabiby.co.tz/bookings/' +
                      booking.ticketNo,
                  subject: 'Pakua tiketi yako');
            })
      ],
      cancelAction: CancelAction(title: Text('SITISHA')),
    );
  }

  Future submit(bool printTicket) async {
    EasyLoading.show(status: 'Inawasilisha...', dismissOnTap: true);

    setState(() {
      isSubmitting = true;
      bookings = [];
    });
    dynamic response =
        await Api.createBooking(selectedSchedule, passengers, selectedMethod);
    if (response is List<BookingModel>) {
      setState(() {
        isSubmitting = false;
        bookings = response;
      });

      Fluttertoast.showToast(
          msg:
              "Umefanikiwa kutunza tiketi, unaweza kuendelea mbele ku chapisha ticket",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.teal.shade800,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
        msg:
            'Imeshindikana kutengeneza tiketi, tafadhali rudia tena au wasiliana na admin kwa msaada zaidi',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    }

    setState(() {
      isSubmitting = false;
    });

    EasyLoading.dismiss();
  }
}
