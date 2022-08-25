import 'package:flutter/material.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/pages/booking/show.dart';
import 'package:repair_service_ui/utils/functions.dart';
import 'package:repair_service_ui/widgets/primary_button.dart';
import 'package:ticket_widget/ticket_widget.dart';

class BookingShow extends StatelessWidget {
  final BookingModel booking;

  BookingShow({Key key, @required this.booking}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.redAccent,
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.redAccent,
            title: Text('TAARIFA YA TIKETI',
                style: TextStyle(fontWeight: FontWeight.w600))),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(left: 15, right: 15, bottom: 30),
                child: Align(
                    alignment: Alignment.topCenter,
                    child: TicketWidget(
                        width: 370,
                        height: MediaQuery.of(context).size.height * 0.75,
                        isCornerRounded: true,
                        margin: EdgeInsets.only(top: 30),
                        padding: EdgeInsets.all(10),
                        child: BookingTicket(booking: booking))))));
  }
}
