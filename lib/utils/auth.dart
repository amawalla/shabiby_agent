import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:repair_service_ui/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../actions/api.dart';
import '../models/model.dart';
import 'session.dart';

class AuthProvider with ChangeNotifier {
  var mainUrl = 'https://pos.shabiby.co.tz/v1/';

  SharedPreferences prefs;

  String _token;
  String _userId;
  User user;
  String _userEmail;
  DateTime _expiryDate;
  Timer _authTimer;
  bool isAutheticated = false;

  bool get isAuth {
    return token != null;
  }

  // ignore: missing_return
  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
  }

  String get userId {
    return _userId;
  }

  String get userEmail {
    return _userEmail;
  }

  Future<dynamic> logout() async {
    _token = null;
    user = null;
    _expiryDate = null;
    dynamic session = Session();
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    Session().remove('access_token');
    Session().remove('id');
    Session().remove('first_name');
    Session().remove('last_name');
    Session().remove('phone');
    Session().remove('email');
    Session().set('logged_in', false);

    notifyListeners();
    return true;
  }

  void _autologout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timetoExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timetoExpiry), logout);
  }

  Future<User> getUser() async {
    return await Session().getUser();
  }

  Future<void> setUser() async {
    user = await Session().getUser();
    notifyListeners();
  }

  Future<void> checkAuth() async {
    isAutheticated = await Session().isLoggedIn();
    notifyListeners();
  }

  Future<bool> refresh() async {
    try {
      final responce = await http
          .post(Uri.parse(Constants.baseURL + 'auth/refresh'), headers: {
        HttpHeaders.authorizationHeader:
            "Bearer " + await Session().get('access_token'),
      });

      if (responce.statusCode == 200) {
        final responceData = json.decode(responce.body.toString());
        _token = responceData['access_token'];
        User user = User.fromJson(responceData['user']);
        notifyListeners();
        Session().set('access_token', _token);
        Session().set('id', user.id);
        Session().set('first_name', user.firstName);
        Session().set('last_name', user.lastName);
        Session().set('phone', user.phone);
        Session().set('email', user.email);
        Session().set('logged_in', true);

        if (user.route != null) {
          Session().set('default_route', user.route.id);
          Session().set('default_route_name', user.route.name);
        }

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> tryautoLogin() async {
    dynamic session = Session();
    if (!session.get('logged_in')) {
      return false;
    }

    final expiryDate = DateTime.parse(session.get('expire_date'));
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = session.get['acess_token'];
    _expiryDate = expiryDate;
    notifyListeners();
    _autologout();
    return true;
  }

  Future<bool> authentication(
      String username, String password, String endpoint) async {
    try {
      String token;
//      token = await FirebaseMessaging.instance.getToken();

      final responce =
          await http.post(Uri.parse(Constants.baseURL + endpoint), body: {
        'username': username,
        'password': password,
        //'fcm_token': token,
      });

      print(responce.statusCode);

      if (responce.statusCode == 200) {
        final responceData = json.decode(responce.body.toString());
        print(responceData['user']);

        _token = responceData['access_token'];
        User user = User.fromJson(responceData['user']);
        //_expiryDate = DateTime.now().add(Duration(seconds: 3600));
        //  _autologout();
        notifyListeners();

        Session().set('access_token', _token);
        Session().set('id', user.id);
        Session().set('first_name', user.firstName);
        Session().set('last_name', user.lastName);
        Session().set('phone', user.phone);
        Session().set('email', user.email);
        Session().set('logged_in', true);
        if (user.route != null) {
          Session().set('default_route', user.route.id);
          Session().set('default_route_name', user.route.name);
        }
        dynamic isLoggedIn = await Session().get("logged_in");
        return isLoggedIn == true;
      } else if (responce.statusCode == 422) {
        Fluttertoast.showToast(
            msg: responce.body.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.brown.shade900,
            textColor: Colors.white,
            fontSize: 16.0);
      }

      return false;
    } on TimeoutException catch (e) {
      Fluttertoast.showToast(
          msg: 'Login failed, please try again',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.brown.shade900,
          textColor: Colors.white,
          fontSize: 16.0);

      print('Timeout Error: $e');
    } on SocketException catch (e) {
      Fluttertoast.showToast(
          msg: 'Please check your internet connection and try again',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.brown.shade900,
          textColor: Colors.white,
          fontSize: 16.0);
      print('Socket Error: $e');
    } on Error catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.brown.shade900,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    return false;
  }

  static Future<bool> login(String username, String password) {
    return AuthProvider().authentication(username, password, 'auth/login');
  }
}
