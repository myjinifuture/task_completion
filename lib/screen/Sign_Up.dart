import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:taskdemo/Services/Services.dart';
class Sign_UP extends StatefulWidget {
  const Sign_UP({Key? key}) : super(key: key);

  @override
  _Sign_UPState createState() => _Sign_UPState();
}

class _Sign_UPState extends State<Sign_UP> {

  TextEditingController _txtmobileno = TextEditingController();
  TextEditingController _txtname = TextEditingController();

  checkSignUp(String name,String mobileNo) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = {
          "MobileNo": mobileNo,
          "Name":name
        };
        Services.responseHandler(apiName: "Member/AddMember", body: body).then(
                (data) async {
              if (data.Data.toString() == "1") {
                Fluttertoast.showToast(
                  msg: data.Message,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  textColor: Colors.green,
                );
                _txtmobileno.text = "";
                _txtname.text = "";
                Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: EdgeInsets.only(top: 72)),
              Lottie.asset("assets/json/task-done.json"),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.blue)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top:14.0),
                  child: TextFormField(
                    controller: _txtname,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Name",
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.blue)
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top:14.0),
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
              Center(
                child: RaisedButton(
                  onPressed: () {
                    checkSignUp(_txtname.text,_txtmobileno.text);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.blue[700],
                  child: Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
