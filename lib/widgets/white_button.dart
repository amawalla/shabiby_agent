import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:repair_service_ui/utils/constants.dart';

class WhiteButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool isLoading;
  WhiteButton({this.text, this.onPressed, this.isLoading});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onPressed,
      child: Container(
        width: double.infinity,
        height: ScreenUtil().setHeight(59.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(32.0),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(3, 3, 3, 0.2),
              spreadRadius: 0,
              blurRadius: 3,
              offset: Offset(0, 6), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: this.isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.redAccent))
              : Text(
                  this.text,
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}
