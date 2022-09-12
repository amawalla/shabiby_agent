import 'dart:convert';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:repair_service_ui/actions/api.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/pages/schedule/show.dart';
import 'package:repair_service_ui/utils/constants.dart';
import 'package:repair_service_ui/utils/functions.dart';
import 'package:repair_service_ui/widgets/primary_button.dart';
import 'package:repair_service_ui/widgets/red_button.dart';
import 'package:skeletons/skeletons.dart';
import 'package:smart_select/smart_select.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../utils/session.dart';
import '../setting/bluetooth/bluetooth.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  TextEditingController _travelDate = TextEditingController(text: null);
  TextEditingController _route = TextEditingController(text: null);
  TextEditingController _schedule = TextEditingController(text: null);
  DateRangePickerController _rangePickerController =
      DateRangePickerController();
  bool scheduleIsLoading = true;
  bool buttonIsLoading = false;
  ScheduleModel selectedSchedule;
  RouteModel selectedRoute;
  List<ScheduleModel> schedules;
  List routes;
  List<S2Choice<String>> boardingPoints;
  List<S2Choice<String>> droppingPoints;
  List<S2Choice<String>> choices;
  List selectedSeats = [];
  List<PassengerModel> passengers = [];
  String passengerMessage;
  bool passengerError = false;
  bool routeIsLoaded = false;
  TabController tabController;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final box = GetStorage();

  Future _onRefresh() async {
    setState(() {
      scheduleIsLoading = true;
    });
    // monitor network fetch
    await fetchSchedules();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _initializeProcess();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _initializeProcess();
    });
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  Future _initializeProcess() async {
    List<RouteModel> routeResponse;
    dynamic storeRoutes = box.read('routes');
    dynamic defaultRoute = await Session().get('default_route');

    routeResponse = await Api.getRoutes();
    if (storeRoutes == null) {
      routeResponse = await Api.getRoutes();
    } else {
      List data = json.decode(storeRoutes);
      routeResponse = data
          .map((e) => RouteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    schedules = defaultRoute != null
        ? await Api.fetchSchedules(
            DateTime.now().toString(), defaultRoute.toString())
        : await Api.fetchTodaySchedules(DateTime.now());

    setState(() {
      _rangePickerController.selectedDate = DateTime.now();
      _travelDate..text = _rangePickerController.selectedDate.toString();
      routes = routeResponse;
      _route.text = defaultRoute != null ? defaultRoute.toString() : null;
      choices = routes
          .map((item) =>
              S2Choice<String>(value: item.id.toString(), title: item.name))
          .toList();
      schedules = schedules;
      scheduleIsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int _index) {
          setState(() {
            tabController.index = _index;
          });
        },
        unselectedItemColor: Colors.white54,
        currentIndex: tabController.index,
        backgroundColor: Colors.redAccent,
        iconSize: 25,
        fixedColor: Colors.white,
        elevation: 6,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
              label: 'Ratiba',
              backgroundColor: Colors.white),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              label: 'Tafuta',
              backgroundColor: Colors.white),
        ],
      ),
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 70,
        backgroundColor: Colors.redAccent,
        elevation: 4.0,
        actions: [
          box.read('is_printer') == false
              ? InkWell(
                  onTap: () => Functions.pushPage(context, BluetoothSetting()),
                  child: Padding(
                      padding: EdgeInsets.all(12),
                      child: box.read('bluetooth_device_connected') != null
                          ? Icon(
                              Icons.bluetooth,
                              color: Colors.redAccent.shade100,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(selectedRoute?.name ?? ' RATIBA ZA MABASI ',
                style: TextStyle(fontSize: 18)),
            SizedBox(
              height: 5,
            ),
            Text(
                DateFormat.yMMMMd().format(
                    _rangePickerController.selectedDate ?? DateTime.now()),
                style: TextStyle(fontSize: 14)),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Skeleton(
                  isLoading: scheduleIsLoading,
                  skeleton: SkeletonListView(),
                  child: renderSchedules())),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: renderSearchContainer(context),
          ),
        ],
      ),
    );
  }

  Future fetchSchedules() async {
    if (_route.text.isNotEmpty && _travelDate.text.isNotEmpty) {
      schedules = await Api.fetchSchedules(_travelDate.text, _route.text);
      if (schedules != null) {
        setState(() {
          schedules = schedules;
          scheduleIsLoading = false;
        });
      }
    }
  }

  Widget renderSearchContainer(BuildContext context) {
    return Column(children: [
      Container(
          margin: EdgeInsets.only(top: 5),
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
              showNavigationArrow: true,
              controller: _rangePickerController,
              onSelectionChanged: (date) async {
                if (date.value is DateTime) {
                  _travelDate.text = DateFormat('yyyy-MM-dd')
                      .format(_rangePickerController.selectedDate);
                }
              })),
      Divider(height: 0),
      choices != null
          ? SmartSelect.single(
              placeholder: 'Chagua safari',
              title: 'CHAGUA SAFARI',
              //selectedValue: _os,
              choiceItems: choices,
              choiceDivider: true,
              modalType: S2ModalType.bottomSheet,
              onChange: (selected) async {
                setState(() {
                  _route = TextEditingController(text: selected.value);
                  selectedRoute = routes.firstWhere(
                      (element) => element.id.toString() == selected.value);
                });
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
              value: selectedRoute != null ? selectedRoute.id.toString() : null,
            )
          : SizedBox(),
      Divider(height: 0),
      SizedBox(
        height: 25.0,
      ),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: () async {
              setState(() {
                buttonIsLoading = true;
              });
              await onSearch();
            },
            child: Container(
              width: double.infinity,
              height: ScreenUtil().setHeight(59.0),
              decoration: BoxDecoration(
                color: Constants.redColor,
                borderRadius: BorderRadius.circular(32.0),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(169, 176, 185, 0.42),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              child: Center(
                child: buttonIsLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white))
                    : Text(
                        'Tafuta Ratiba',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ))
    ]);
  }

  onSearch() async {
    bool move = false;
    if (_route.text.isNotEmpty && _travelDate.text.isNotEmpty) {
      try {
        dynamic scheduleResponse =
            await Api.fetchSchedules(_travelDate.text, _route.text);
        if (scheduleResponse is List<ScheduleModel>) {
          move = true;
        } else {
          Fluttertoast.showToast(
            msg:
                'Hakuna ratiba zimepatikana, tafadhali jaribu siku au safari nyingine',
            backgroundColor: Colors.indigo,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
          );
        }
        schedules = scheduleResponse;
        tabController.animateTo(0, curve: Curves.easeInOut);
        tabController.addListener(() {
          _setSchedules(schedules, move);
        });
      } catch (e) {
        Fluttertoast.showToast(
            msg: 'TATIZO\nTafadhali jaribu tena au anza upya',
            backgroundColor: Colors.redAccent,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR);

        print(e);
      }
    }
    _setSchedules(schedules, move);
  }

  void _setSchedules(schedules, move) {
    setState(() {
      buttonIsLoading = false;
      schedules = schedules;
    });
  }

  renderSchedules() {
    return SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        enablePullDown: true,
        enablePullUp: false,
        header: MaterialClassicHeader(
            color: Colors.white, backgroundColor: Colors.redAccent),
        child: schedules == null || schedules.isEmpty
            ? EmptyWidget(
                hideBackgroundAnimation: true,
                titleTextStyle: Theme.of(context)
                    .typography
                    .dense
                    .headline5
                    .copyWith(color: Colors.black87),
                subtitleTextStyle: Theme.of(context)
                    .typography
                    .dense
                    .caption
                    .copyWith(color: Colors.black87),
                title: 'Hakuna Ratiba',
                subTitle: 'Tafadhali chagua tarehe au safari nyingine',
              )
            : ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(height: 3, color: Colors.grey),
                physics: ClampingScrollPhysics(),
                itemCount: schedules != null ? schedules.length : 1,
                itemBuilder: (context, index) {
                  ScheduleModel schedule = schedules[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white),
                      child: ListTile(
                        isThreeLine: true,
                        dense: true,
                        enableFeedback: true,
                        title: Text(
                          schedule.route,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87.withOpacity(0.8)),
                        ),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Text(schedule.name,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                  'Jumla ya Tiketi:  ' +
                                      (schedule.totalBookings.toString()),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87)),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                  'Siti zilizopo:  ' +
                                      schedule.totalAvailableSeats.toString(),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87)),
                              SizedBox(
                                height: 2,
                              ),
                              Text(schedule.visibility)
                            ]),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(schedule.date),
                            SizedBox(
                              height: 5,
                            ),
                            FittedBox(
                                child: LinearPercentIndicator(
                              padding: EdgeInsets.all(0),
                              width: 80,
                              lineHeight: 4.0,
                              percent: schedule.progressPercentage / 100,
                              progressColor: getPercentageColor(schedule),
                            ))
                          ],
                        ),
                        onTap: () {
                          showAdaptiveActionSheet(
                            context: context,
                            title: Column(
                              children: [
                                Text('RATIBA YA BASI',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18)),
                                SizedBox(height: 10),
                                Text(schedule.name),
                                SizedBox(height: 5),
                                Text(schedule.route),
                                SizedBox(height: 5),
                                Divider(color: Colors.black54)
                              ],
                            ),
                            androidBorderRadius: 30,
                            isDismissible: true,
                            actions: <BottomSheetAction>[
                              BottomSheetAction(
                                  title: const Text('Onesha Tiketi za Abiria'),
                                  onPressed: (context) async {
                                    return Functions.pushPage(context,
                                        ScheduleShowPage(schedule: schedule));
                                  }),
                              BottomSheetAction(
                                  title: const Text('Chapa Manifesti'),
                                  onPressed: (context) async {
                                    await EasyLoading.show(
                                        status: 'Printing Seat Plan ',
                                        dismissOnTap: true);

                                    await Functions.printSeatPlan(
                                        context, schedule);
                                    await EasyLoading.dismiss();
                                  }),
                              BottomSheetAction(
                                  title: const Text('Chapa Tiketi Zote'),
                                  onPressed: (context) async {
                                    EasyLoading.show(
                                        status: 'Inachapisha Tiketi ',
                                        dismissOnTap: true);
                                    List<BookingModel> bookings =
                                        await Api.getBookings(schedule);
                                    if (bookings != null) {
                                      await Functions.batchPrintBookings(
                                          context, bookings);
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: 'Hakuna tiketi ya kuchapa',
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        toastLength: Toast.LENGTH_LONG,
                                      );
                                    }
                                    EasyLoading.dismiss();
                                  }),
                            ],
                            cancelAction:
                                CancelAction(title: const Text('SITISHA')),
                          );
                        },
                      ),
                    ),
                  );
                }));
  }

  getPercentageColor(ScheduleModel scheduleModel) {
    if (scheduleModel.progressPercentage > 30 &&
        scheduleModel.progressPercentage <= 80) {
      return Colors.orangeAccent.shade400;
    }
    if (scheduleModel.progressPercentage > 80) {
      return Colors.red;
    }

    return Colors.green;
  }
}
