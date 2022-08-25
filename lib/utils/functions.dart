import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:repair_service_ui/models/model.dart';
import 'package:repair_service_ui/pages/setting/bluetooth/print_helper.dart';
import 'package:repair_service_ui/utils/constants.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

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

  static Future printTicket(BuildContext context, ticket) async {
    try {
      // await SunmiPrinter.bindingPrinter();
      Uint8List byte = (await NetworkAssetBundle(Uri.parse(Constants.baseURL +
                  'bookings/' +
                  ticket.toString() +
                  '/download'))
              .load(Constants.baseURL +
                  'bookings/' +
                  ticket.toString() +
                  '/download'))
          .buffer
          .asUint8List();

      print('Printing Ticket ' + ticket.toString());
      await SunmiPrinter.startTransactionPrint(true);
      await SunmiPrinter.printImage(byte);
      await SunmiPrinter.submitTransactionPrint();
      await SunmiPrinter.exitTransactionPrint(true); // Close the transaction

      //  await SunmiPrinter.unbindingPrinter();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha tiketi  ' +
            ticket.toString() +
            ', tafadhali jaribu tena',
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );

      print(e);
    }
  }

  static Future printTicketBluetooth(BuildContext context, ticket) async {
    try {
      // await SunmiPrinter.bindingPrinter();
      Uint8List byte = (await NetworkAssetBundle(Uri.parse(Constants.baseURL +
                  'bookings/' +
                  ticket.toString() +
                  '/download'))
              .load(Constants.baseURL +
                  'bookings/' +
                  ticket.toString() +
                  '/download'))
          .buffer
          .asUint8List();

      print('Printing Ticket ' + ticket.toString());
      await BluetoothPrinter().printImageByte(byte);
      //  await SunmiPrinter.unbindingPrinter();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha tiketi  ' +
            ticket.toString() +
            ', tafadhali jaribu tena',
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );

      print(e);
    }
  }

  static Future batchPrintTickets(
      BuildContext context, ScheduleModel scheduleModel) async {
    try {
      Uint8List byte = (await NetworkAssetBundle(Uri.parse(Constants.baseURL +
                  'bookings/batch_download?schedule=' +
                  scheduleModel.scheduleNo))
              .load(Constants.baseURL +
                  'bookings/batch_download?schedule=' +
                  scheduleModel.scheduleNo))
          .buffer
          .asUint8List();

      print('Printing Ticket');
      await SunmiPrinter.startTransactionPrint(true);
      await SunmiPrinter.printImage(byte);
      await SunmiPrinter.submitTransactionPrint();
      await SunmiPrinter.exitTransactionPrint(true); // Close the transaction
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha tiketi, tafadhali jaribu tena',
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      print(e);
    }
  }

  static Future batchPrintTicketsViaBluetoth(
      BuildContext context, ScheduleModel scheduleModel) async {
    try {
      Uint8List byte = (await NetworkAssetBundle(Uri.parse(Constants.baseURL +
                  'bookings/batch_download?schedule=' +
                  scheduleModel.scheduleNo))
              .load(Constants.baseURL +
                  'bookings/batch_download?schedule=' +
                  scheduleModel.scheduleNo))
          .buffer
          .asUint8List();

      print('Printing Tickets');
      await BluetoothPrinter().printImageByte(byte);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha tiketi, tafadhali jaribu tena',
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      print(e);
    }
  }

  static Future printSeatPlan(
      BuildContext context, ScheduleModel scheduleModel) async {
    try {
      Uint8List byte = (await NetworkAssetBundle(Uri.parse(Constants.baseURL +
                  'schedules/' +
                  scheduleModel.scheduleNo +
                  '/manifest'))
              .load(Constants.baseURL +
                  'schedules/' +
                  scheduleModel.scheduleNo +
                  '/manifest'))
          .buffer
          .asUint8List();

      print('Printing Schedule Manifesto');
      await SunmiPrinter.startTransactionPrint(true);
      await SunmiPrinter.printImage(byte);
      await SunmiPrinter.submitTransactionPrint();
      await SunmiPrinter.exitTransactionPrint(true); // Close the transaction

    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha manifesto, tafadhali jaribu tena',
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
      print(e);
    }
  }

  static Future printSeatPlanBluetooth(
      BuildContext context, ScheduleModel scheduleModel) async {
    try {
      // await SunmiPrinter.bindingPrinter();
      Uint8List byte = (await NetworkAssetBundle(Uri.parse(Constants.baseURL +
                  'schedules/' +
                  scheduleModel.scheduleNo +
                  '/manifest'))
              .load(Constants.baseURL +
                  'schedules/' +
                  scheduleModel.scheduleNo +
                  '/manifest'))
          .buffer
          .asUint8List();
      print('Printing Tickets');

      await BluetoothPrinter().printImageByte(byte);
      //  await SunmiPrinter.unbindingPrinter();
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Imeshindikana kuchapisha manifesto, tafadhali jaribu tena',
        backgroundColor: Colors.redAccent,
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
