import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  Future _onRefresh() async {
    setState(() {
      scheduleIsLoading = true;
    });
    // monitor network fetch
    await _initializeProcess();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    _initializeProcess();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _initializeProcess();
    });
    tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  Future _initializeProcess() async {
    List<RouteModel> routeResponse = await Api.getRoutes();
    schedules = await Api.fetchTodaySchedules(DateTime.now());
    setState(() {
      _rangePickerController.selectedDate = DateTime.now();
      _travelDate..text = _rangePickerController.selectedDate.toString();
      routes = routeResponse;
      choices = routes
          .map((item) =>
              S2Choice<String>(value: item.id.toString(), title: item.name))
          .toList();
      schedules = schedules;
      scheduleIsLoading = false;
    });
  }

  TabBar get _tabBar => TabBar(
        indicatorColor: Colors.white,
        onTap: (c) {
          setState(() {
            buttonIsLoading = false;
          });
        },
        controller: tabController,
        tabs: [
          Tab(
            icon: Icon(Icons.search_rounded),
          ),
          Tab(
            icon: Icon(Icons.calendar_today),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        brightness: Brightness.light,
        elevation: 3.0,
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: _tabBar.preferredSize,
            child: Material(
              elevation: 3,
              color: Colors.redAccent,
              child: _tabBar,
            )),
        title: const Text(
          'RATIBA ZA MABASI',
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: renderSearchContainer(context),
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              child: Skeleton(
                  isLoading: scheduleIsLoading,
                  skeleton: SkeletonListView(),
                  child: renderSchedules())),
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
          margin: EdgeInsets.only(top: 20),
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
                  _travelDate.text = DateFormat('yyyy-MM-dd')
                      .format(_rangePickerController.selectedDate);
                  //await fetchSchedules();
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
        tabController.animateTo(1, curve: Curves.easeInOut);
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
        header: MaterialClassicHeader(),
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
                              Text(schedule.name),
                              SizedBox(
                                height: 2,
                              ),
                              Text('Jumla ya Tiketi:  ' +
                                  (schedule.totalBookings.toString())),
                              SizedBox(
                                height: 2,
                              ),
                              Text('Siti zilizopo:  ' +
                                  schedule.totalAvailableSeats.toString()),
                              SizedBox(
                                height: 2,
                              ),
                              Text('Jumla ya siti:  ' +
                                  schedule.totalSeats.toString()),
                              SizedBox(
                                height: 2,
                              ),
                              Text('Siti zilizohifadhiwa:  ' +
                                  schedule.totalReservedSeats.toString()),
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
                                Text('RATIBA YA BASI - ' + schedule.scheduleNo,
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
                                    EasyLoading.show(
                                        status: 'Printing Seat Plan ',
                                        dismissOnTap: true);
                                    await Functions.printSeatPlan(
                                        context, schedule);
                                    EasyLoading.dismiss();
                                  }),
                              BottomSheetAction(
                                  title: const Text('Chapa Manifesti'),
                                  onPressed: (context) async {
                                    EasyLoading.show(
                                        status:
                                            'Printing Seat Plan ( Bluetooth ) ',
                                        dismissOnTap: true);
                                    await Functions.printSeatPlanBluetooth(
                                        context, schedule);
                                    EasyLoading.dismiss();
                                  }),
                              BottomSheetAction(
                                  title: const Text('Chapa Tiketi Zote'),
                                  onPressed: (context) async {
                                    EasyLoading.show(
                                        status: 'Printing Tiketi ',
                                        dismissOnTap: true);
                                    List<BookingModel> bookings =
                                        await Api.getBookings(schedule);
                                    if (bookings != null) {
                                      for (BookingModel booking in bookings) {
                                        print('Printing ' + booking.ticketNo);
                                        await Functions.printTicket(
                                            context, booking.ticketNo);
                                      }
                                    } else {
                                      EasyLoading.showError(
                                          'Hakuna tiketi za kuchapa');
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
