import 'dart:typed_data';
import 'printrenum.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

///Test printing
class TestPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  sample() async {
    //image max 300px X 300px

    ///image from Asset

    ///image from Network
    var response = await http.get(
        Uri.parse("https://pos.shabiby.co.tz/v1/bookings/9146765027/download"));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    bluetooth.isConnected.then((isConnected) {
      print(isConnected);
      if (isConnected == true) {
        bluetooth.printImageBytes(imageBytesFromNetwork);
      }
    });
  }
}
