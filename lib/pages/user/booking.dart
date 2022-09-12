import 'dart:math';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:repair_service_ui/actions/api.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/pages/booking/booking.dart';
import 'package:repair_service_ui/pages/request_service_flow.dart';
import 'package:repair_service_ui/pages/user/profile.dart';
import 'package:repair_service_ui/utils/functions.dart';
import 'package:repair_service_ui/utils/helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletons/skeletons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class UserBookingPage extends StatefulWidget {
  UserBookingPage({Key key}) : super(key: key);

  @override
  _UserBookingPageState createState() => _UserBookingPageState();
}

class _UserBookingPageState extends State<UserBookingPage> {
  final GlobalKey<ScaffoldState> mainDrawerKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoaded = true;
  List<BookingModel> bookings;
  List<BookingModel> selectedBookings;
  List<bool> isSelected = [];
  bool isAllChecked = false;
  bool multModeEnabled = false;
  DateTime todayDate = DateTime.now();
  CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  DateTime _selectedDateAppBBar;

  @override
  void initState() {
    super.initState();
    _initializePage();
    _selectedDateAppBBar = DateTime.now();
  }

  Future _onRefresh() async {
    setState(() {
      isLoaded = false;
    });
    // monitor network fetch
    await _initializePage();
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _initializePage();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  Future<dynamic> _initializePage() async {
    List<BookingModel> bookingReponse =
        await Api.getUserBookings(_selectedDateAppBBar ?? todayDate);
    setState(() {
      bookings = bookingReponse;
      isLoaded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CalendarAgenda(
          controller: _calendarAgendaControllerAppBar,
          appbar: true,
          selectedDayPosition: SelectedDayPosition.right,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          weekDay: WeekDay.long,
          fullCalendarScroll: FullCalendarScroll.horizontal,
          fullCalendarDay: WeekDay.long,
          selectedDateColor: Colors.redAccent.shade400,
          initialDate: DateTime.now(),
          calendarEventColor: Colors.redAccent,
          firstDate: DateTime.now().subtract(Duration(days: 140)),
          lastDate: DateTime.now(),
          onDateSelected: (date) async {
            setState(() {
              isLoaded = true;
              _selectedDateAppBBar = date;
            });
            await _initializePage();
          },
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 5),
          child: Skeleton(
            skeleton: SkeletonListView(),
            child: _renderBookings(),
            isLoading: isLoaded,
          ),
        )
        // body:
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

  Widget _renderBookings() {
    return SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        enablePullDown: true,
        enablePullUp: false,
        header: MaterialClassicHeader(),
        child: bookings == null || bookings.isEmpty
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
                title: 'Hakuna Tiketi',
                subTitle: 'Tafadhali chagua tarehe nyingine',
              )
            : ListView.separated(
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
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: booking.statusColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              spreadRadius: 0,
                              blurRadius: 1,
                              offset:
                                  Offset(0, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                            child: Text(
                          booking.seatNo,
                          style: TextStyle(
                              fontSize: 17,
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
                            Text(
                              booking.ticketNo,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 2,
                            ),
                            Text(booking.schedule.name,
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            SizedBox(
                              height: 2,
                            ),
                            Text(booking.issuedAt,
                                style: TextStyle(
                                    color: Colors.black87.withOpacity(0.7),
                                    fontSize: 12)),
                          ]),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.schedule.date ?? '',
                            style: TextStyle(fontSize: 12),
                          ),
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
                }));
  }
}
