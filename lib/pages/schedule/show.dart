import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:repair_service_ui/actions/api.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/utils/functions.dart';
import 'package:repair_service_ui/utils/helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletons/skeletons.dart';

class ScheduleShowPage extends StatefulWidget {
  ScheduleShowPage({Key key, this.schedule}) : super(key: key);
  final ScheduleModel schedule;

  @override
  _ScheduleShowPageState createState() => _ScheduleShowPageState();
}

class _ScheduleShowPageState extends State<ScheduleShowPage> {
  final GlobalKey<ScaffoldState> mainDrawerKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  bool isLoaded = true;
  List<BookingModel> bookings;
  List<BookingModel> selectedBookings;
  List<bool> isSelected = [];
  bool isAllChecked = false;

  @override
  void initState() {
    super.initState();
    _initializePage();
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
    // monitor network fetch
    _initializePage();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  Future<dynamic> _initializePage() async {
    List<BookingModel> bookingReponse = await Api.getBookings(widget.schedule);
    setState(() {
      isLoaded = false;
      bookings =
          bookingReponse != null ? bookingReponse : widget.schedule.bookings;

      if (bookingReponse != null) {
        isSelected = [];
        for (var item in bookingReponse) {
          isSelected.add(false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.redAccent,
          elevation: 4.0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.schedule.route,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              SizedBox(
                height: 5,
              ),
              Text(widget.schedule.date + ' -  ' + widget.schedule.scheduleNo,
                  style: TextStyle(fontSize: 13)),
              SizedBox(
                height: 5,
              ),
              Text(widget.schedule.name,
                  textAlign: TextAlign.start, style: TextStyle(fontSize: 13)),
            ],
          ),
          actions: [
            isSelected != null && isSelected.where((e) => e == true).isNotEmpty
                ? Checkbox(
                    checkColor: Colors.redAccent,
                    fillColor: MaterialStateProperty.all(Colors.white),
                    value: isAllChecked,
                    onChanged: (bool value) {
                      setState(() {
                        isAllChecked = !isAllChecked;
                        if (bookings != null && isSelected != null) {
                          for (var i = 0; i < isSelected.length; i++) {
                            isSelected[i] = value;
                          }
                        }
                      });
                    },
                  )
                : SizedBox(),
            isSelected != null && isSelected.where((e) => e == true).isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () => showMultiSelectionMenu(context),
                  )
                : SizedBox()
          ],
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

  showMultiSelectionMenu(BuildContext context) {
    showAdaptiveActionSheet(
        context: context,
        title: Column(
          children: [
            Text('Hariri Tiketi Ulizochagua', style: TextStyle(fontSize: 20)),
            Divider(color: Colors.black54)
          ],
        ),
        androidBorderRadius: 30,
        isDismissible: true,
        actions: <BottomSheetAction>[
          BottomSheetAction(
              title: Text('Chapa Tiketi ( ' +
                  (isSelected != null
                          ? isSelected
                              .where((element) => element == true)
                              .length
                          : 0)
                      .toString() +
                  ' )'),
              onPressed: (context) async {
                if (isSelected != null && bookings != null) {
                  for (var i = 0;
                      i < isSelected.where((e) => e == true).length;
                      i++) {
                    BookingModel bookingModal = bookings[i];
                    EasyLoading.show(
                        status: 'Printing Tiketi ' +
                            bookingModal.ticketNo.toString(),
                        dismissOnTap: true);
                    await Functions.printTicket(context, bookingModal.ticketNo);
                    print(bookingModal.ticketNo);
                  }
                }

                EasyLoading.dismiss();
              }),
        ],
        cancelAction: CancelAction(
            title: Text('SITISHA'),
            onPressed: (v) {
              if (bookings != null && isSelected != null) {
                for (var i = 0; i < isSelected.length; i++) {
                  isSelected[i] = false;
                }
              }
            }));
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
            title: const Text('Badili Siti'),
            onPressed: (context) async {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Itakuja hivi punde')),
              );
            }),
        BottomSheetAction(
            title: const Text('Piga Simu'),
            onPressed: (context) async {
              await Helper.launchURL('tel:' + booking.phone);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(booking.phone)),
              );
            }),
        BottomSheetAction(
            title: const Text('Chapa Tiketi'),
            onPressed: (context) async {
              EasyLoading.show(
                  status: 'Printing Tiketi ' + booking.ticketNo.toString(),
                  dismissOnTap: true);
              await Functions.printTicket(context, booking.ticketNo);
              EasyLoading.dismiss();
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
                subTitle: 'Tafadhali reload au tafuta ratiba nyingine',
              )
            : ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(height: 3, color: Colors.grey),
                physics: ClampingScrollPhysics(),
                itemCount: bookings != null ? bookings.length : 1,
                itemBuilder: (context, index) {
                  BookingModel booking = bookings[index];
                  return Container(
                    decoration: BoxDecoration(
                        color: isSelected != null && isSelected[index]
                            ? Colors.grey.shade300
                            : Colors.white),
                    child: ListTile(
                      selectedColor: Colors.black,
                      selected: isSelected != null && isSelected[index],
                      onLongPress: () {
                        if (isSelected != null) {
                          setState(() {
                            isSelected[index] = !isSelected[index];
                          });
                        }
                      },
                      leading: FittedBox(
                          child: isSelected != null && isSelected[index]
                              ? CircleAvatar(
                                  backgroundColor: Colors.redAccent,
                                  child: Icon(Icons.check, color: Colors.white))
                              : Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black38,
                                        spreadRadius: 0,
                                        blurRadius: 1,
                                        offset: Offset(
                                            0, 1), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                      child: Text(
                                    booking.seatNo,
                                    style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.w600),
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
                            Text('Kituo cha kupandia:  ' +
                                booking.boardingPoint),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                                'Kituo cha kushukia:  ' + booking.droppingPoint)
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
                }));
  }
}
