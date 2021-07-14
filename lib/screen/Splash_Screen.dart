import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskdemo/Common/constant.dart';
import 'package:taskdemo/screen/Homescreen.dart';
import 'package:taskdemo/screen/Login_Screen.dart';

class Splash_Screen extends StatefulWidget {

  @override
  _Splash_ScreenState createState() => _Splash_ScreenState();
}

class _Splash_ScreenState extends State<Splash_Screen> {
  String adminid = "";

  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(seconds: 4), () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var id = prefs.getString("_id");
      adminid = prefs.getString(Login.isAdmin).toString();
      if (id == null) {
         Navigator.push(
           context,MaterialPageRoute(builder: (context) => Login_Screen()));
      } else {
         Navigator.pushAndRemoveUntil(
           context,
         MaterialPageRoute(builder: (context) => Home_Screen(adminid)),
         (route) => false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[50],
        body: Container(
          margin: EdgeInsets.only(top: 110),
          child: Center(
            child: Lottie.asset('assets/json/splash.json', width: 250)))
    ,
    );
  }
}
