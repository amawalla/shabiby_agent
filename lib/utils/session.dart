import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/model.dart';

class Session {
  /// Initialize session container
  Map _session = {};

  // Yes, it uses SharedPreferences
  SharedPreferences prefs;

  // Initialize the SharedPreferences instance
  Future _initSharedPrefs() async {
    this.prefs = await SharedPreferences.getInstance();
  }

  /// Item setter
  ///
  /// @param key String
  /// @returns Future
  Future get(key) async {
    await _initSharedPrefs();
    try {
      return json.decode(this.prefs.get(key));
    } catch (e) {
      return this.prefs.get(key);
    }
  }

  /// Item setter
  ///
  /// @param key String
  /// @param value any
  /// @returns Future
  Future set(key, value) async {
    await _initSharedPrefs();

    // Detect item type
    switch (value.runtimeType) {
      // String
      case String:
        {
          this.prefs.setString(key, value);
        }
        break;

      // Integer
      case int:
        {
          this.prefs.setInt(key, value);
        }
        break;

      // Boolean
      case bool:
        {
          this.prefs.setBool(key, value);
        }
        break;

      // Double
      case double:
        {
          this.prefs.setDouble(key, value);
        }
        break;

      // List<String>
      case List:
        {
          this.prefs.setStringList(key, value);
        }
        break;

      // Object
      default:
        {
          this.prefs.setString(key, jsonEncode(value.toJson()));
        }
    }

    // Add item to session container
    this._session.putIfAbsent(key, () => value);
  }

  Future remove(key) async {
    await _initSharedPrefs();
    try {
      return this.prefs.remove(key);
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<bool> isLoggedIn() async {
    await _initSharedPrefs();
    try {
      return this.prefs.get('logged_in') == true;
    } catch (e) {
      return false;
    }
  }

  Future<User> getUser() async {
    await _initSharedPrefs();
    try {
      var userConfig = {
        'first_name': this.prefs.get('first_name'),
        'last_name': this.prefs.get('last_name'),
        'phone_number': this.prefs.get('phone'),
        'email': this.prefs.get('email'),
        'id': this.prefs.get('id'),
        'route': this.prefs.get('route'),
      };
      User user = User.fromJson(userConfig);
      return user;
    } catch (e) {
      throw (e);
      return null;
    }
  }
}
