import 'package:flutter/material.dart';
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
}
