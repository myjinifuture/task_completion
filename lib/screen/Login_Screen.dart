import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskdemo/Common/constant.dart';
import 'package:taskdemo/Services/Services.dart';
import 'Homescreen.dart';
import 'Sign_Up.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FORM_STATE,
  SHOW_OTPFORM_STATE,
}

class Login_Screen extends StatefulWidget {
  const Login_Screen({Key? key}) : super(key: key);

  @override
  _Login_ScreenState createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  TextEditingController _txtmobileno = TextEditingController();
  TextEditingController _txtOtp = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;


  checkLogin(String mobileNo) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = {"MobileNo": mobileNo};
        Services.responseHandler(apiName: "Member/Login", body: body).then(
                (data) async {
              if (data.Data.length > 0) {
                prefs.setString(
                    Login.isAdmin, data.Data[0]["IsAdmin"].toString());
                print(data.Data[0]["IsAdmin"]);
                prefs.setString(Login.Id, data.Data[0]["_id"]);
                var adminid = prefs.getString(Login.Id);
                print(adminid);

                prefs.setString(Login.name, data.Data[0]["Name"]);
                Fluttertoast.showToast(
                  msg: data.Message,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  textColor: Colors.green,
                );
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Home_Screen(data.Data[0]["IsAdmin"].toString())),
                        (route) => false);
                _txtmobileno.text = "";
              } else {
                Fluttertoast.showToast(
                  msg: data.Message,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.black45,
                  timeInSecForIosWeb: 1,
                  textColor: Colors.red,
                );
              }
            }, onError: (e) {
          //  showMsg("$e");
        });
      } else {
        //showMsg("No Internet Connection.");
      }
    } on SocketException catch (_) {
      // showMsg("Something Went Wrong");
      setState(() {
        //stateLoading = false;
      });
    }
  }

  String verificationId = "";

  getMobileFormWidget(context) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: 72)),
            Lottie.asset("assets/json/task-done.json"),
            Padding(padding: EdgeInsets.only(top: 52)),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.blue, width: 1)),
              child: Padding(
                padding: EdgeInsets.only(top: 14),
                child: TextFormField(
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                  controller: _txtmobileno,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Mobile Number",
                    hintText: "Enter Number",
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10.0)),
            // ignore: deprecated_member_use
            RaisedButton(
              onPressed: () async {
                await _auth.verifyPhoneNumber(
                    phoneNumber: "+91"+_txtmobileno.text,
                    verificationCompleted: (phoneAuthCredential) async {
                    signInWithPhoneAuthCreditial(phoneAuthCredential);
                    },
                    verificationFailed: (verificationFailed) async {
                      _scaffoldkey.currentState!.showSnackBar(
                          SnackBar(content: Text("verification Failed")));
                    },
                    codeSent: (verificationId, resendingToken) async {
                      setState(() {
                        currentState =
                            MobileVerificationState.SHOW_OTPFORM_STATE;
                        this.verificationId = verificationId;
                      });
                    },
                    codeAutoRetrievalTimeout: (verificationId) async {});
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.blue[700],
              child: Text(
                "SEND",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Sign_UP()));
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.blue[700],
              child: Text(
                "Sign Up",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getOtpFormWidget(context) {
    return Column(
      children: [
        Padding(padding: EdgeInsets.only(top: 200)),
        TextFormField(
          controller: _txtOtp,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter OTP",
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        SizedBox(
          height: 16,
        ),
        RaisedButton(
          onPressed: () {
            PhoneAuthCredential phoneAuthcreditial = PhoneAuthProvider
                .credential(verificationId: verificationId, smsCode: _txtOtp.text);
                 signInWithPhoneAuthCreditial(phoneAuthcreditial);
          },
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: Colors.blue[700],
          child: Text(
            "Verify",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ],
    );
  }

  void signInWithPhoneAuthCreditial(PhoneAuthCredential phoneAuthcreditial)async {
    try {
      final authCreditial = await _auth.signInWithCredential(phoneAuthcreditial);
      if(authCreditial.user != null){
        print("check login");
        checkLogin(_txtmobileno.text);
      }
    } on FirebaseAuthException catch (e) {
      print("otp verify");
        _scaffoldkey.currentState!.showSnackBar(SnackBar(content: Text("otp Verified..")));
    }
  }

  GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldkey,
        backgroundColor: Colors.blue[50],
        body: Container(
          child: currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
              ? getMobileFormWidget(context)
              : getOtpFormWidget(context),
          padding: EdgeInsets.all(16),
        ));
  }
}


