import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:scoped_model/scoped_model.dart';
import '../utils/constants.dart';

class Bluetooth extends Model {
  static final Bluetooth _singleton = new Bluetooth._internal();

  factory Bluetooth() {
    return _singleton;
  }
  Bluetooth._internal();

  FlutterBlue _flutterBlue = FlutterBlue.instance;

  /// Scanning
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map();
  bool isScanning = false;

  /// State
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  /// Device
  BluetoothDevice device;
  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = new List();
  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  /// Device metrics
  int heartRate;
  int respirationRate;
  int stepCount;
  double activity;
  int cadence;
  int battery;

  void init() {
    // Immediately get the state of FlutterBlue
    _flutterBlue.startScan(timeout: Duration(seconds: 4)).then((s) {
      state = s;
      print('State init: $state');
      notifyListeners();
    });
    // Subscribe to state change
    // /*
  }

  void dispose() {
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
  }

  void startScan() {
    scanResults = new Map();
    _scanSubscription = _flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
    )
        .listen((scanResult) {
      if (scanResult.advertisementData.localName.startsWith('HX-')) {
        scanResults[scanResult.device.id] = scanResult;
        notifyListeners();
      }
    }, onDone: stopScan);

    isScanning = true;
    notifyListeners();
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    isScanning = false;
    notifyListeners();
  }

  connect(BluetoothDevice d) async {
    device = d;
    print('Connecting device ' + d.name);

    // Subscribe to connection changes
  }

  disconnect() {
    // Remove all value changed listeners
    valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    valueChangedSubscriptions.clear();
    // deviceStateSubscription?.cancel();
    // deviceStateSubscription = null;
    //deviceConnection?.cancel();
    // deviceConnection = null;
    device = null;
    notifyListeners();
  }

  _getCharacteristic(String charUUID) {
    BluetoothCharacteristic characteristic;
    for (BluetoothService s in services) {
      for (BluetoothCharacteristic c in s.characteristics) {
        if (c.uuid.toString() == charUUID) {
          characteristic = c;
        }
      }
    }
    return characteristic;
  }
}
