import 'package:app_settings/app_settings.dart';
import 'package:get_storage/get_storage.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:repair_service_ui/utils/session.dart';
import 'package:repair_service_ui/widgets/primary_button.dart';
import 'package:repair_service_ui/widgets/red_button.dart';
import 'package:repair_service_ui/widgets/white_button.dart';
import 'package:smart_select/smart_select.dart';

import 'print_helper.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';

class BluetoothSetting extends StatefulWidget {
  @override
  _BluetoothSettingState createState() => new _BluetoothSettingState();
}

class _BluetoothSettingState extends State<BluetoothSetting> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isConnecting = false;
  bool _isOff = false;
  BluetoothPrinter printerBlueetooth = BluetoothPrinter();
  final box = GetStorage();
  bool isPrinting = false;
  String statusText;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {}

    try {
      bluetooth.onStateChanged().listen((state) async {
        switch (state) {
          case BlueThermalPrinter.CONNECTED:
            setState(() {
              _connected = true;
              statusText = 'Kifaa kimeunganishwa ';
            });
            break;
          case BlueThermalPrinter.DISCONNECTED:
            setState(() {
              _connected = false;
              print("bluetooth device state: disconnected");
            });
            break;
          case BlueThermalPrinter.DISCONNECT_REQUESTED:
            setState(() {
              _connected = false;
              print("bluetooth device state: disconnect requested");
            });
            break;
          case BlueThermalPrinter.STATE_TURNING_OFF:
            setState(() {
              _isOff = true;
              _connected = false;
              show("Tafadhali washa bluetooth ya simu yako");
            });
            break;
          case BlueThermalPrinter.STATE_OFF:
            setState(() {
              _isOff = true;
              statusText = 'Washa bluetooth kuunga kifaa';
              _connected = false;
              show("Tafadhali washa bluetooth ya simu yako");
            });
            break;
          case BlueThermalPrinter.STATE_ON:
            setState(() {
              statusText = 'Chagua kifaa kuunga';
              _connected = false;
              print("bluetooth device state: bluetooth on");
            });
            break;
          case BlueThermalPrinter.STATE_TURNING_ON:
            setState(() {
              _connected = false;
              statusText = 'Kifaa hakijaunganihswa';
              print("bluetooth device state: bluetooth turning on");
            });
            break;
          case BlueThermalPrinter.ERROR:
            setState(() {
              _connected = false;
              show("Kumetokea tatizo, tafadhali jaribu tena");
            });
            break;
          default:
            print(state);
            break;
        }
      });

      if (!mounted) return;
      setState(() {
        box.write('bluetooth_device_connected', _connected);
        _devices = devices;
      });

      if (isConnected == true) {
        setState(() {
          statusText = 'Kifaa kimeunganihswa ';
          _connected = true;
        });
      }
    } catch (e) {
      // / print(e);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // TODO: implement dispose
    bluetooth.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        actions: [
          box.read('is_printer') == false
              ? InkWell(
                  onTap: () => AppSettings.openBluetoothSettings(),
                  child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        Icons.settings_bluetooth,
                        color: Colors.white54,
                        size: 28,
                      )),
                )
              : SizedBox()
        ],
        elevation: 0,
        backgroundColor: Colors.redAccent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: const Text(
          'Tafuta Vifaa',
          style:
              TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        onPressed: () => initPlatformState(),
        backgroundColor: Colors.white,
        icon: const Icon(
          Icons.search,
          color: Colors.redAccent,
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ListView(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(3, 3, 3, 0.2),
                                spreadRadius: 0,
                                blurRadius: 3,
                                offset:
                                    Offset(0, 6), // changes position of shadow
                              ),
                            ],
                          ),
                          child: SmartSelect.single(
                            placeholder: 'Chagua kifaa cha bluetooth',
                            title: 'CHAGUA KIFAA',
                            //selectedValue: _os,
                            choiceItems: _getDeviceChoices(),
                            choiceDivider: true,
                            modalType: S2ModalType.bottomSheet,
                            onChange: (selected) async {
                              print(selected.value);
                              setState(() {
                                _device = _devices.firstWhere(
                                    (element) =>
                                        element.address == selected.value,
                                    orElse: () => null);
                              });
                              box.write('bluetooth_printer', _device.address);
                              box.write('bluetooth_device', _device.address);
                              box.write('bluettoth_device_name', _device.name);
                            },
                            // modalType: S2ModalType.bottomSheet,
                            tileBuilder: (context, state) {
                              return S2Tile.fromState(
                                state,
                                enabled: _getDeviceChoices() != null,
                                isLoading: _getDeviceChoices() == null,
                                isTwoLine: true,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 0),
                                leading: const Icon(Icons.bluetooth_searching,
                                    size: 40, color: Colors.redAccent),
                              );
                            },
                            value: _device != null
                                ? _device.address
                                : box.read('bluetooth_device'),
                          )))
                ],
              ),
              SizedBox(height: 80),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 20,
                  ),
                  RawMaterialButton(
                    onPressed: _connected ? _disconnect : _connect,
                    elevation: 10.0,
                    fillColor: _connected && _device != null
                        ? Colors.white12.withOpacity(0.9)
                        : Colors.white12.withOpacity(0.7),
                    child: Icon(
                        _connected && _device != null
                            ? Icons.bluetooth_connected
                            : Icons.bluetooth_disabled,
                        size: 150,
                        color: Colors.redAccent),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: Text(statusText ?? ' Device is disconnected',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              SizedBox(height: 20),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10.0, right: 10.0, top: 20),
                    child: WhiteButton(
                        text: 'TIKETI YA MAJARIBIO',
                        isLoading: isPrinting,
                        onPressed: () async {
                          setState(() {
                            isPrinting = true;
                          });

                          await printerBlueetooth
                              .printSampleImage()
                              .whenComplete(() {
                            setState(() {
                              isPrinting = false;
                            });
                          });
                        }),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  List<S2Choice<String>> _getDeviceChoices() {
    List<S2Choice<String>> items = [];
    if (_devices.isEmpty) {
      items.add(S2Choice<String>(value: '0', title: 'No Device'));
    } else {
      _devices.forEach((device) {
        items.add(S2Choice<String>(value: device.address, title: device.name));
      });
    }
    return items;
  }

  void _connect() async {
    if (_device != null) {
      bluetooth.isConnected.then((isConnected) async {
        bluetooth.connect(_device).catchError((error) {
          setState(() => _connected = false);
        });

        box.write('bluetooth_device', _device.address);
        box.write('bluettoth_device_name', _device.name);
        box.write('bluetooth_device_connected', true);
        setState(() {
          _connected = true;
          statusText = 'Kifaa kimeunganishwa';
        });
      });
    } else {
      box.write('bluetooth_device_connected', false);
      show('Tafuta au chagua kifaa kabla ya kuunganisha');
    }
  }

  void _disconnect() async {
    bluetooth.disconnect();
    box.write('bluetooth_device_connected', false);
    box.remove('bluettoth_device_name');
    box.remove('bluetooth_device');
    setState(() {
      _connected = false;
      statusText = 'Device is disconnected';
    });
  }

  Future show(
    String message, {
    Duration duration: const Duration(seconds: 3),
  }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }
}
