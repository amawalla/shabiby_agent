import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/auth.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInFiveState();
}

class _SignInFiveState extends State<SignInPage> {
  bool _isLoading = false;
  TextEditingController _username = TextEditingController(text: '');
  TextEditingController _password = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: <Widget>[
              //left side background design. I use a svg image here
              Positioned(
                left: -34,
                top: 181.0,
                child: SvgPicture.string(
                  // Group 3178
                  '<svg viewBox="-34.0 181.0 99.0 99.0" ><path transform="translate(-34.0, 181.0)" d="M 74.25 0 L 99 49.5 L 74.25 99 L 24.74999618530273 99 L 0 49.49999618530273 L 24.7500057220459 0 Z" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(-26.57, 206.25)" d="M 0 0 L 42.07500076293945 16.82999992370605 L 84.15000152587891 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(15.5, 223.07)" d="M 0 56.42999649047852 L 0 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                  width: 99.0,
                  height: 99.0,
                ),
              ),

              //right side background design. I use a svg image here
              Positioned(
                right: -52,
                top: 45.0,
                child: SvgPicture.string(
                  // Group 3177
                  '<svg viewBox="288.0 45.0 139.0 139.0" ><path transform="translate(288.0, 45.0)" d="M 104.25 0 L 139 69.5 L 104.25 139 L 34.74999618530273 139 L 0 69.5 L 34.75000762939453 0 Z" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(298.42, 80.45)" d="M 0 0 L 59.07500076293945 23.63000106811523 L 118.1500015258789 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /><path transform="translate(357.5, 104.07)" d="M 0 79.22999572753906 L 0 0" fill="none" stroke="#ffffff" stroke-width="1" stroke-opacity="0.25" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
                  width: 139.0,
                  height: 139.0,
                ),
              ),

              //content ui
              Positioned(
                top: 60.0,
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //logo section
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              logo(size.height / 4, size.height / 4),
                              richText(23.12),
                              const SizedBox(
                                height: 20,
                              ),
                              emailTextField(size),
                              const SizedBox(
                                height: 8,
                              ),
                              passwordTextField(size),
                              const SizedBox(
                                height: 20,
                              ),
                              buildRememberForgetSection(),
                              const SizedBox(
                                height: 16,
                              ),
                              signInButton(size),
                              const SizedBox(
                                height: 30,
                              ),
                              buildFooter(size)
                            ],
                          ),
                        ),

                        //email and password TextField here
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget logo(double height_, double width_) {
    return Image.asset(
      'assets/images/msafiri-white.png',
      height: height_,
      width: width_,
    );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: 23.12,
          color: Colors.white,
          letterSpacing: 1.999999953855673,
        ),
        children: const [
          TextSpan(
            text: 'SHABIBY',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'LINE',
            style: TextStyle(
              color: Color(0xFFFE9879),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget emailTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.redAccent.shade100,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //mail icon
            const Icon(
              Icons.mail_rounded,
              color: Colors.white70,
            ),
            const SizedBox(
              width: 16,
            ),

            //divider svg
            SvgPicture.string(
              '<svg viewBox="99.0 332.0 1.0 15.5" ><path transform="translate(99.0, 332.0)" d="M 0 0 L 0 15.5" fill="none" fill-opacity="0.6" stroke="#ffffff" stroke-width="1" stroke-opacity="0.6" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
              width: 1.0,
              height: 15.5,
            ),
            const SizedBox(
              width: 16,
            ),

            //email address textField
            Expanded(
              child: TextField(
                controller: _username,
                maxLines: 1,
                cursorColor: Colors.white70,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                    hintText: 'Namba ya simu au barua pepe',
                    hintStyle: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFooter(Size size) {
    return Align(
      alignment: Alignment.center,
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: 'Powered by Logitek Solutions',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget passwordTextField(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.redAccent.shade100,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            //lock logo here
            const Icon(
              Icons.lock,
              color: Colors.white70,
            ),
            const SizedBox(
              width: 16,
            ),

            //divider svg
            SvgPicture.string(
              '<svg viewBox="99.0 332.0 1.0 15.5" ><path transform="translate(99.0, 332.0)" d="M 0 0 L 0 15.5" fill="none" fill-opacity="0.6" stroke="#ffffff" stroke-width="1" stroke-opacity="0.6" stroke-miterlimit="4" stroke-linecap="butt" /></svg>',
              width: 1.0,
              height: 15.5,
            ),
            const SizedBox(
              width: 16,
            ),

            //password textField
            Expanded(
              child: TextField(
                controller: _password,
                maxLines: 1,
                cursorColor: Colors.white70,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                    hintText: 'Ingiza namba ya siri',
                    hintStyle: TextStyle(
                      fontSize: 15.0,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    suffixIcon: const Icon(
                      Icons.visibility,
                      color: Colors.white70,
                    ),
                    border: InputBorder.none),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRememberForgetSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          const Spacer(),
          Text(
            'Nimesahau neno la siri',
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget signInButton(Size size) {
    return InkWell(
        onTap: () async {
          if (_username.text.isNotEmpty && _password.text.isNotEmpty) {
            setState(() {
              _isLoading = true;
            });
            await attemptLogIn(_username.text, _password.text);
          } else {
            Fluttertoast.showToast(
                msg:
                    'Tafadhali jaza namba yako ya simu/email pamoja na password',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.white,
                textColor: Colors.redAccent,
                fontSize: 16.0);
          }
        },
        child: Container(
          alignment: Alignment.center,
          height: size.height / 13,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.redAccent))
              : Text(
                  'Ingia',
                  style: TextStyle(
                    fontSize: 17.0,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ));
  }

  Future<bool> attemptLogIn(String username, String password) async {
    try {
      bool response = await AuthProvider.login(username, password);
      if (response) {
        Phoenix.rebirth(context);
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }
}
