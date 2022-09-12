import 'dart:typed_data';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../../utils/constants.dart';
import 'package:flutter/services.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as Imag;

class BluetoothPrinter {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;

  bool get mounted => null;
  final box = GetStorage();

  Future printSample() async {
    //image max 300px X 300px

    final response = await http
        .get(Uri.parse(Constants.baseURL + 'bookings/914293075/download'));

    if (response.statusCode == 200) {
      bluetooth.isConnected.then((isConnected) async {
        if (isConnected == true) {
          await bluetooth.paperCut();
          await bluetooth.printImageBytes(response.bodyBytes);
          //bluetooth.paperCut();
          //  await bluetooth.drawerPin5();
          await bluetooth.drawerPin2();
        }
      });
    }
  }

  Future<void> printSampleImage() async {
    final response = await http
        .get(Uri.parse(Constants.baseURL + 'bookings/914293075/download'));

    if (response.statusCode == 200) {
      print('Printin sample');

      await printImageByte(response.bodyBytes);
    }
  }

  Future<void> connect() async {
    final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: box.read('bluetooth_device'));
    print("State conected $result");
  }

  checkIfConnected() async {
    return bluetooth.isConnected;
  }

  Future<bool> initializePrinter() async {
    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      if (devices != null) {
        return await connectToDevice(devices);
      }
    } catch (e) {
      print(e);
      print('Printer no connected');
      print('Configure printer to use ');
    }

    return false;
  }

  Future<bool> connectPrinter(BluetoothDevice device) async {
    print('Connecting printer');
    await GetStorage().write('bluetooth_device_connected', true);
    await GetStorage().write('bluetooth_device', device.address);
    await GetStorage().write('bluetooth_device_name', device.name);
    await bluetooth.connect(device);
    return true;
  }

  Future disconnectPrinter() async {
    await PrintBluetoothThermal.disconnect;
  }

  Future<bool> connectToDevice(List<BluetoothDevice> devices) async {
    if (devices.isNotEmpty) {
      try {
        dynamic bDevice = await GetStorage().read('bluetooth_device');
        print(bDevice);
        bluetooth.isConnected.then((isConnected) async {
          _device = bDevice != null
              ? devices.firstWhere((element) => element.address == bDevice)
              : _device;
          if (_device != null) {
            return await connectPrinter(_device);
          }
        });
      } catch (e) {
        print(e);
      }
    }
    return false;
  }

  printImageByte(Uint8List byte, [bool isBatch]) async {
    print('Is Batch is {$isBatch}');
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    print("State conected 1 $connectionStatus");
    if (!connectionStatus) {
      String macAddess = box.read('bluetooth_device');
      print(macAddess);
      connectionStatus =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddess);
      print("State conected 2 $connectionStatus");
    }

    if (connectionStatus) {
      print("state conected 3 $connectionStatus");
      List<int> bytes = [];
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm72, profile);
      bytes += generator.reset();
      final Uint8List bytesImg = byte.buffer.asUint8List();
      final image = Imag.decodeImage(bytesImg);
      bytes += generator.image(image);
      bytes += generator.cut();
      await PrintBluetoothThermal.writeBytes(bytes);
      if (isBatch != true) {
        print('Checkick if its batch');
        await PrintBluetoothThermal.disconnect;
      }
      return;
    } else {
      Fluttertoast.showToast(
          msg: "Tafadhali unganisha kifaa kwanza kabla ya kuchapa tiketi",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.brown.shade900,
          textColor: Colors.white,
          fontSize: 16.0);
      print("There's no connection");
    }
  }

  printImageBatchByte(Uint8List byte) async {
    bool blueToothEnabled =
        await PrintBluetoothThermal.isPermissionBluetoothGranted &&
            await PrintBluetoothThermal.isPermissionBluetoothGranted;

    if (blueToothEnabled) {
      bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
      print("State conected 1 $connectionStatus");
      if (!connectionStatus) {
        String macAddess = box.read('bluetooth_device');
        print(macAddess);
        connectionStatus =
            await PrintBluetoothThermal.connect(macPrinterAddress: macAddess);
        await Future.delayed(Duration(seconds: 1));
        print("State conected 2 $connectionStatus");
        // final r = RetryOptions(maxAttempts: 2);
        // return await r.retry(printImageByte(byte));
      }

      if (connectionStatus) {
        print("state conected 3 $connectionStatus");
        List<int> bytes = [];
        final profile = await CapabilityProfile.load();
        final generator = Generator(PaperSize.mm72, profile);
        bytes += generator.reset();
        final Uint8List bytesImg = byte.buffer.asUint8List();
        final image = Imag.decodeImage(bytesImg);
        bytes += generator.image(image);
        bytes += generator.cut();
        await PrintBluetoothThermal.writeBytes(bytes);
        return;
      } else {
        Fluttertoast.showToast(
            msg: "Tafadhali unganisha kifaa kwanza kabla ya kuchapa tiketi",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.brown.shade900,
            textColor: Colors.white,
            fontSize: 16.0);

        print("There's connection");
      }
    }
  }

  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    bluetooth.onStateChanged().listen((state) async {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          print("bluetooth device state: connected");
          _connected = true;

          break;
        case BlueThermalPrinter.DISCONNECTED:
          print("bluetooth device state: disconnected");
          _connected = false;
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          print("bluetooth device state: disconnect requested");
          _connected = false;
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          print("bluetooth device state: bluetooth turning off");
          _connected = false;
          break;
        case BlueThermalPrinter.STATE_OFF:
          print("bluetooth device state: bluetooth off");
          _connected = false;
          break;
        case BlueThermalPrinter.STATE_ON:
          print("bluetooth device state: bluetooth on");
          _connected = false;
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          print("bluetooth device state: bluetooth turning on");
          _connected = true;
          break;
        case BlueThermalPrinter.ERROR:
          print("bluetooth device state: error");
          _connected = false;
          break;
        default:
          break;
      }
    });

    //if (!mounted) return;
    return devices;
  }
}
