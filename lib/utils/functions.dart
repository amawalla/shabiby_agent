import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/pages/setting/bluetooth/print_helper.dart';
import 'package:repair_service_ui/utils/constants.dart';
import 'package:flutter_sunmi_printer/flutter_sunmi_printer.dart' as sm;

class Functions {
  static Future pushPage(BuildContext context, Widget page) {
    var val = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );

    return val;
  }

  static Future printTicket(BuildContext context, ticket,
      [bool isBatch]) async {
    try {
      final box = GetStorage();

      if (box.read('is_printer') != true) {
        return await printTicketBluetooth(context, ticket, isBatch);
      }
      final response = await http.get(Uri.parse(
          Constants.baseURL + 'bookings/' + ticket.toString() + '/download'));
      if (response.statusCode == 200) {
        print('Printing Ticket ' + ticket.toString());
        await sm.SunmiPrinter.image(
            base64.encode(Uint8List.view(response.bodyBytes.buffer)));
      } else {
        print(response.statusCode);
        print('Sunmi imekataa');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha tiketi  ' +
            ticket.toString() +
            ', tafadhali jaribu tena',
        backgroundColor: Colors.brown.shade900,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );

      print(e);
    }
  }

  static Future printTicketBluetooth(BuildContext context, ticket,
      [bool isBatch]) async {
    try {
      final response = await http.get(Uri.parse(
          Constants.baseURL + 'bookings/' + ticket.toString() + '/download'));

      if (response.statusCode == 200) {
        print('Printing Ticket ' + ticket.toString());
        await BluetoothPrinter().printImageByte(response.bodyBytes, isBatch);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha tiketi  ' +
            ticket.toString() +
            ', tafadhali jaribu tena',
        backgroundColor: Colors.brown.shade900,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );

      print(e);
    }
  }

  static Future batchPrintBookings(
      BuildContext context, List<BookingModel> bookings) async {
    final box = GetStorage();
    if (box.read('is_printer') != true) {
      return await batchPrintBookingsViaBluetoth(context, bookings);
    }
    try {
      await Future.forEach(bookings, (element) async {
        print('Printing ' + element.ticketNo);
        EasyLoading.show(
            status: 'Inachapisha Tiketi ' + element.ticketNo,
            dismissOnTap: true);
        await Functions.printTicket(context, element.ticketNo);
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha tiketi, tafadhali jaribu tena',
        backgroundColor: Colors.brown.shade900,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      print(e);
    }
  }

  static Future batchPrintBookingsViaBluetoth(
      BuildContext context, List<BookingModel> bookings) async {
    try {
      await Future.forEach(bookings, (element) async {
        print('Printing ' + element.ticketNo);
        EasyLoading.show(
            status: 'Inachapisha Tiketi ' + element.ticketNo,
            dismissOnTap: true);
        await Functions.printTicket(context, element.ticketNo, true);
      }).whenComplete(() async {
        await BluetoothPrinter().disconnectPrinter();
      });
      EasyLoading.dismiss();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha tiketi, tafadhali jaribu tena',
        backgroundColor: Colors.brown.shade900,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      print(e);
    }
  }

  static Future printSeatPlan(
      BuildContext context, ScheduleModel scheduleModel) async {
    final box = GetStorage();
    if (box.read('is_printer') != true) {
      return await printSeatPlanBluetooth(context, scheduleModel);
    }
    try {
      final response = await http.get(Uri.parse(Constants.baseURL +
          'schedules/' +
          scheduleModel.scheduleNo +
          '/manifest'));

      if (response.statusCode == 200) {
        print('Found ticket');
        print('Printing Schedule Manifesto');
        await sm.SunmiPrinter.image(
            base64.encode(Uint8List.view(response.bodyBytes.buffer)));
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha manifesto, tafadhali jaribu tena',
        backgroundColor: Colors.brown.shade900,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      print(e);
    }
  }

  static Future printSeatPlanBluetooth(
      BuildContext context, ScheduleModel scheduleModel) async {
    try {
      final response = await http.get(Uri.parse(Constants.baseURL +
          'schedules/' +
          scheduleModel.scheduleNo +
          '/manifest'));

      if (response.statusCode == 200) {
        print('Printing Tickets');
        await BluetoothPrinter().printImageByte(response.bodyBytes);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha manifesto, tafadhali jaribu tena',
        backgroundColor: Colors.brown.shade900,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );

      print(e);
    }
  }

  static Future pushPageDialog(BuildContext context, Widget page) {
    var val = Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
        fullscreenDialog: true,
      ),
    );

    return val;
  }

  static pushPageReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
    );
  }

  static pushPageReplacementUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return page;
        },
      ),
      (Route<dynamic> route) => false,
    );
  }

  static isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static bool checkConnectionError(e) {
    if (e.toString().contains('SocketException') ||
        e.toString().contains('HandshakeException')) {
      return true;
    } else {
      return false;
    }
  }
}
