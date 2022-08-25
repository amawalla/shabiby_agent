import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:repair_service_ui/actions/api.dart';
import 'package:repair_service_ui/models/model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/enum/api_request_status.dart';
import '../utils/functions.dart';

class SettingProvider extends ChangeNotifier {
  ScrollController controller = ScrollController();
  List items = List();
  List routes;
  int page = 1;
  bool loadingMore = false;
  bool loadMore = true;
  APIRequestStatus routeRequestStatus = APIRequestStatus.loading;

  fetchRoute() {
    setApiRequestStatus(APIRequestStatus.loading);
    Api.getRoutes().then((item) {
      routes = item;
      setApiRequestStatus(APIRequestStatus.loaded);
    }).catchError((e) {
      checkError(e);
      Fluttertoast.showToast(
        msg: '$e',
        toastLength: Toast.LENGTH_SHORT,
      );
      throw (e);
    });
  }

  void checkError(e) {
    if (Functions.checkConnectionError(e)) {
      setApiRequestStatus(APIRequestStatus.connectionError);
    } else {
      setApiRequestStatus(APIRequestStatus.error);
    }
  }

  void setApiRequestStatus(APIRequestStatus value) {
    routeRequestStatus = value;
    notifyListeners();
  }
}
