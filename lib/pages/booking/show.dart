import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/utils/functions.dart';
import 'package:repair_service_ui/widgets/primary_button.dart';

class BookingTicket extends StatefulWidget {
  final BookingModel booking;

  BookingTicket({Key key, @required this.booking}) : super(key: key);

  @override
  _BookingTicketState createState() => _BookingTicketState();
}

class _BookingTicketState extends State<BookingTicket> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Center(
              child: Text(
            widget.booking.ticketNo,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                fontWeight: FontWeight.bold),
          )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ticketDetailsWidget('Abiria', widget.booking.name, 'Status',
                  widget.booking.status),
              SizedBox(height: 10),
              ticketDetailsWidget('Safari', widget.booking.route.name,
                  'Siti ya Abiria', widget.booking.seatNo),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              ticketDetailsWidget(
                  'Tarehe ya Safari',
                  widget.booking.schedule.date ?? '',
                  'Muda wa Kundoka',
                  widget.booking.departureTime),
              SizedBox(height: 5),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ticketDetailsWidget(
                  'Kiasi cha Nauli',
                  'TSh ' + widget.booking.fare + '/=',
                  'Tarehe ya Malipo',
                  widget.booking.createdAt),
              SizedBox(height: 15),
              ticketDetailsWidget(
                  'Kituo cha Kupanda',
                  widget.booking.boardingPoint ?? 'Hakuna',
                  'Kituo cha Kushuka',
                  widget.booking.droppingPoint ?? 'Hakuna'),
              SizedBox(height: 20),
            ],
          ),
        ),
        Center(
          heightFactor: 0.1,
          child: Text(
            widget.booking.receipt ?? '',
            style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 10),
        Center(
            child: Text(
          'Imetolewa na: ' + (widget.booking.issuedBy ?? 'Self Booking'),
        )),
        SizedBox(height: 5),
        Center(
            child: Text(widget.booking.issuedAt,
                style: TextStyle(color: Colors.black54))),
        SizedBox(height: 10),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: PrimaryButton(
              isLoading: isLoading,
              text: 'Print Ticket',
              onPressed: () async {
                if (widget.booking.confirmed) {
                  setState(() {
                    isLoading = true;
                  });
                  await Functions.printTicket(context, widget.booking.ticketNo);
                  setState(() {
                    isLoading = false;
                  });
                } else {
                  Fluttertoast.showToast(
                    msg: 'Tiketi hii haijalipiwa/kuhakikiwa',
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    toastLength: Toast.LENGTH_LONG,
                  );
                }
              },
            ))
      ],
    ));
  }
}

Widget ticketDetailsWidget(String firstTitle, String firstDesc,
    String secondTitle, String secondDesc) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              firstTitle,
              style: const TextStyle(color: Colors.black54),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                firstDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              secondTitle,
              style: const TextStyle(color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                secondDesc,
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            )
          ],
        ),
      )
    ],
  );
}
