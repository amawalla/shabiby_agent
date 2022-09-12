import 'package:flutter/material.dart';

class Constants {
  static String baseURL = 'https://pos.shabiby.co.tz/v1/';

  static String appCastURL =
      'https://shabiby.co.tz/app/android/wakala/appcast.xml';

  static final Color primaryColor = Color.fromRGBO(18, 26, 28, 1);
  static final Color redColor = Colors.redAccent;
  static final Color greyColor = Color.fromRGBO(247, 247, 249, 1);

  static final String batteryServiceUUID =
      "0000180f-0000-1000-8000-00805f9b34fb";
  static final String batteryMeasurementUUID =
      "00002a19-0000-1000-8000-00805f9b34fb";

  static final String heartRateServiceUUID =
      "0000180d-0000-1000-8000-00805f9b34fb";
  static final String heartRateMeasurementUUID =
      "00002a37-0000-1000-8000-00805f9b34fb";

  static final String respirationRateServiceUUID =
      "3b55c581-bc19-48f0-bd8c-b522796f8e24";
  static final String respirationRateMeasurementUUID =
      "9bc730c3-8cc0-4d87-85bc-573d6304403c";

  static final String accelerometerServiceUUID =
      "bdc750c7-2649-4fa8-abe8-fbf25038cda3";
  static final String accelerometerMeasurementUUID =
      "75246a26-237a-4863-aca6-09b639344f43";
}
