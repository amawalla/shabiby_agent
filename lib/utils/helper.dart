import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class Helper {
  static void nextPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return page;
      }),
    );
  }

  static Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Imeshindikana $url';
    }
  }

  static handleDioError(e) {
    if (e is DioError) {
      if (e.type == DioErrorType.connectTimeout ||
          e.type == DioErrorType.sendTimeout) {
        Fluttertoast.showToast(
          msg: 'Please check your internet connection and try again',
          backgroundColor: Colors.brown.shade900,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        switch (e.response.statusCode) {
          case 401:
            Fluttertoast.showToast(
              msg: 'Un -Authorised - Please log in again to continue',
              backgroundColor: Colors.brown.shade900,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );

            break;
          case 422:
            Fluttertoast.showToast(
              msg: e.response.data.toString(),
              backgroundColor: Colors.brown.shade900,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
            break;
          default:
            Fluttertoast.showToast(
              msg:
                  'Tatizo, limetokea, tafadhali, jaribu tena au wasiliana na mtoa huduma',
              backgroundColor: Colors.brown.shade900,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
            );
            break;
        }
      }
    }

    print(e);
  }
}
