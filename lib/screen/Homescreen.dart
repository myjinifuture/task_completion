import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskdemo/Common/constant.dart';
import 'package:taskdemo/Services/Services.dart';
import 'package:taskdemo/screen/Login_Screen.dart';

// ignore: must_be_immutable
class Home_Screen extends StatefulWidget {
  String isAdmin;
  Home_Screen(this.isAdmin);

  @override
  _Home_ScreenState createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
  TextEditingController _txtadd = TextEditingController();
  TextEditingController _txtSearch = TextEditingController();

  List taskData = [];
  bool isDataFiltered = false;
  bool isName = false;
  bool isSearch = false;
  bool isCompleteTask = false;
  var paddtop = Padding(padding: EdgeInsets.only(top: 5.0));
  DateTime completedate = DateTime.now();
  bool islogout = false;

  @override
  void initState() {
    // TODO: implement initState
    print("admin id");
    print(widget.isAdmin);
    if (widget.isAdmin == "1") {
      setState(() {
        getAllTask("Admin/ShowTasks");
      });
    } else {
      setState(() {
        getAllTask("Tasks/ShowTasks");
      });
    }
    super.initState();
  }

  List filtereTaskNames = [];
  List filterPickedName = [];

  filteredName(String value) {
    setState(() {
      filtereTaskNames = taskData
          .where((name) => name["Member-Details"][0]["Name"]
              .toString()
              .toLowerCase()
              .contains(value.toString().toLowerCase()))
          .toList();
      filterPickedName = pickeddata
          .where((name) => name["Member-Details"][0]["Name"]
              .toString()
              .toLowerCase()
              .contains(value.toString().toLowerCase()))
          .toList();
    });
  }

  searchBar() {
    return Row(
      children: [
        !isSearch
            ? Row(
                children: [
                  Text(
                    "Search By Name...",
                    style: TextStyle(fontSize: 16),
                  ),
                  Padding(padding: EdgeInsets.only(left: 155))
                ],
              )
            : Container(
                width: 285,
                child: TextField(
                  controller: _txtSearch,
                  onChanged: filteredName,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    icon: Icon(
                      Icons.search,
                      size: 25,
                    ),
                    hintText: "Search...",
                  ),
                ),
              ),
        Padding(padding: EdgeInsets.only(left: 5)),
        isSearch
            ? IconButton(
                icon: Icon(Icons.cancel),
                onPressed: () {
                  setState(() {
                    this.isSearch = false;
                  });
                },
              )
            : IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  setState(() {
                    this.isSearch = true;
                  });
                },
              )
      ],
    );
  }

  addTask(String addTask) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var id = prefs.getString(Login.Id);
        print(id);
        var body = {
          "MemberId": id,
          "Task": addTask,
          "TaskAddDate": DateTime.now().toString(),
        };
        Services.responseHandler(apiName: "Tasks/AddTask", body: body).then(
          (data) async {
            if (data.Data.length > 0) {
              widget.isAdmin == "1"
                  ? getAllTask("Admin/ShowTasks")
                  : getAllTask("Tasks/ShowTasks");
              Fluttertoast.showToast(
                msg: data.Message,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black38,
                textColor: Colors.green,
              );
              Navigator.pop(context);
              _txtadd.text = "";
            }
          },
        );
      }
    } on SocketException catch (_) {}
  }

  TaskUpdate(String id) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = {
          "TaskId": id,
          "IsTaskCompleted": true,
          "TaskCompleteDate": DateTime.now().toString(),
        };
        Services.responseHandler(apiName: "Tasks/UpdateTask", body: body).then(
            (data) async {
          print(body);
          if (data.Data == "1") {
            print("No data found");
          } else {
            Fluttertoast.showToast(
              msg: "Task Completed..",
              backgroundColor: Colors.black38,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              textColor: Colors.green,
            );
            getAllTask("Tasks/ShowTasks");
          }
        }, onError: (e) {});
      }
    } on SocketException catch (_) {}
  }

  getAllTask(String api) async {
    final result = await InternetAddress.lookup('google.com');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      var id = prefs.getString(Login.Id);
      var body;
      if (widget.isAdmin == "1") {
        body = {};
      } else {
        body = {"MemberId": id};
      }
      Services.responseHandler(apiName: api, body: body).then((data) async {
        if (data.Data.length > 0) {
          setState(() {
            filtereTaskNames = data.Data;
            taskData = data.Data;
            isDataFiltered = false;
            pickeddata.clear();
          });
        }
      }, onError: (e) {
        //  showMsg("$e");
      });
    }
  }
  DateTime _fromDateTime = new DateTime.now();

  List pickeddata = [];

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _fromDateTime,
        firstDate: new DateTime(2021),
        lastDate: new DateTime(2024));

    if (picked != null && picked != _fromDateTime) {
      pickeddata.clear();
      setState(() {
        filterPickedName = pickeddata;
        isDataFiltered = true;
        for (int i = 0; i < taskData.length; i++) {
          print("comparedate");
          print(picked);
          print(DateTime.parse(taskData[i]["TaskAddDate"]));
          if (picked.compareTo(DateTime.parse(taskData[i]["TaskAddDate"]
                  .toString()
                  .replaceAll(
                      taskData[i]["TaskAddDate"].toString().split(' ')[1],
                      "00:00:00.000"))) ==
              0) {
            pickeddata.add(taskData[i]);
          }
        }
        print("picked data length");
        print(pickeddata.length);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Home Screen"),
        centerTitle: true,
        leading: IconButton(icon:Icon(Icons.logout) , onPressed: () {
          logOutDialogopen();
        },),
        actions: [
          IconButton(
              onPressed: () {
                    _selectDate(context);
              },
              icon: Icon(Icons.calendar_today_sharp))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            widget.isAdmin == "1" ? searchBar() : Container(),
            Padding(padding: EdgeInsets.only(top: 8.0)),
            AllList(),
          ],
        ),
      ),
    );
  }

  logOutDialogopen() {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  backgroundColor: Colors.white,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: Text("Are you sure you want to \n logout ..?",style: TextStyle(fontSize: 16),),
                  content: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    FlatButton(
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        islogout = true;
                        setState(() {
                        prefs.clear();
                        });
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>Login_Screen()), (route) => false);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: islogout ? Colors.blue[50]: Colors.blue[700],
                      child: Text(
                        "Logout",
                        style: TextStyle(color:islogout?Colors.red: Colors.white, fontSize: 20),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 10.0)),
                    FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.blue[700],
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ]),
                )),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Column(
            children: [],
          );
        });
  }

  AllList(){
    return Expanded(
      child: Stack(
        children: [
          pickeddata.length > 0
              ? filterPickedName.length > 0
              ? ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: filterPickedName.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return pickedDataList(index);
            },
          )
              : Center(
            child: CircularProgressIndicator(),
          )
              : taskData.length > 0 && !isDataFiltered
              ? filtereTaskNames.length > 0
              ? ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: filtereTaskNames.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Listviewitem(index);
            },
          )
              : Center(
            child: CircularProgressIndicator(),
          )
              : Center(
              child: Column(children: [
                Padding(
                    padding: EdgeInsets.only(
                        top: filtereTaskNames.length > 0
                            ? 105
                            : 175)),
                Container(
                    width: 100,
                    height: 100,
                x    child: Lottie.asset(
                        "assets/json/splash_loader.json")),
                filtereTaskNames.length > 0
                    ? Text(
                  "No Data Found...!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                )
                    : Container()
              ])),
          Align(
            alignment: Alignment.bottomRight,
            child: widget.isAdmin == "1"
                ? Container()
                : FloatingActionButton(
              onPressed: () {
                AlertDialogopen();
              },
              child: Icon(
                Icons.add,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pickedDataList(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        elevation: 5,
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(children: [
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                widget.isAdmin == "1"
                    ? Text(
                        "Name",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      )
                    : Container(),
                widget.isAdmin == "1" ? paddtop : Container(),
                Text(
                  "Date",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                paddtop,
                Text(
                  "Task",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ]),
              Padding(padding: EdgeInsets.only(top: 5.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isAdmin == "1"
                      ? Text(
                          "       :    ",
                          style: TextStyle(fontSize: 14),
                        )
                      : Container(),
                  widget.isAdmin == "1" ? paddtop : Container(),
                  Text(
                    "       :    ",
                    style: TextStyle(fontSize: 14),
                  ),
                  paddtop,
                  Text(
                    "       :    ",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 5.0)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                widget.isAdmin == "1"
                    ? Text(
                        filterPickedName[index]["Member-Details"][0]["Name"],
                        style: TextStyle(fontSize: 14),
                      )
                    : Container(),
                widget.isAdmin == "1" ? paddtop : Container(),
                Text(
                  DateFormat('dd MMMM yyyy  hh:mm').format(
                      DateTime.parse(filterPickedName[index]["TaskAddDate"])),
                  style: TextStyle(fontSize: 14),
                ),
                paddtop,
                Container(
                  width: MediaQuery.of(context).size.width/1.8,
                  child: Text(
                    filterPickedName[index]["Task"],
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ]),
            ]),
            Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ignore: deprecated_member_use
                RaisedButton(
                    onPressed: () {
                      widget.isAdmin == "1"
                          ? null
                          :
                      filtereTaskNames[index]["IsTaskCompleted"]
                          ? null
                          :
                      TaskUpdate(filtereTaskNames[index]["_id"]);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: filtereTaskNames[index]["IsTaskCompleted"]
                        ? Colors.green
                        : Colors.white,
                    child: filtereTaskNames[index]["IsTaskCompleted"]
                        ? Text(
                            "Completed",
                            style: TextStyle(
                                fontSize: 14,
                                color: filtereTaskNames[index]
                                        ["IsTaskCompleted"]
                                    ? Colors.white
                                    : Colors.black),
                          )
                        :  Text("Not Completed")),
                filtereTaskNames[index]["TaskCompleteDate"] == ""
                    ? Container()
                    : FlatButton(
                        onPressed: () {},
                        child: Text(
                          DateFormat('dd MMMM yyyy  hh:mm').format(
                              DateTime.parse(
                                  filterPickedName[index]["TaskAddDate"])),
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        ),
                      )
              ],
            )
          ]),
        ),
      ),
    );
  }

  Listviewitem(index) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 6,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                widget.isAdmin == "1"
                    ? Text(
                        "Name",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      )
                    : Container(),
                widget.isAdmin == "1" ? paddtop : Container(),
                Text(
                  "Date",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                paddtop,
                Text(
                  "Task",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ]),
              Padding(padding: EdgeInsets.only(top: 5.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isAdmin == "1"
                      ? Text(
                          "       :    ",
                          style: TextStyle(fontSize: 14),
                        )
                      : Container(),
                  widget.isAdmin == "1" ? paddtop : Container(),
                  Text(
                    "       :    ",
                    style: TextStyle(fontSize: 14),
                  ),
                  paddtop,
                  Text(
                    "       :    ",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 5.0)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isAdmin == "1"
                      ? Text(
                          filtereTaskNames[index]["Member-Details"][0]["Name"],
                          style: TextStyle(fontSize: 14),
                        )
                      : Container(),
                  widget.isAdmin == "1" ? paddtop : Container(),
                  Text(
                    DateFormat('dd MMMM yyyy  hh:mm').format(
                        DateTime.parse(filtereTaskNames[index]["TaskAddDate"])),
                    style: TextStyle(fontSize: 14),
                  ),
                  paddtop,
                  Container(
                    width: MediaQuery.of(context).size.width/1.8,
                    child: Text(
                      filtereTaskNames[index]["Task"],
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ]),
            Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                    onPressed: () {
                      widget.isAdmin == "1"
                          ? null
                          :
                      filtereTaskNames[index]["IsTaskCompleted"]
                          ? null
                          : TaskUpdate(filtereTaskNames[index]["_id"]);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    color: filtereTaskNames[index]["IsTaskCompleted"]
                        ? Colors.green
                        : Colors.white,
                    child: filtereTaskNames[index]["IsTaskCompleted"]
                        ? Text(
                            "Completed",
                            style: TextStyle(
                                fontSize: 14,
                                color: filtereTaskNames[index]
                                        ["IsTaskCompleted"]
                                    ? Colors.white
                                    : Colors.black),
                          )
                        : Text(
                            "Not Completed",
                            style: TextStyle(
                                fontSize: 14,
                                color: filtereTaskNames[index]
                                        ["IsTaskCompleted"]
                                    ? Colors.white
                                    : Colors.black),
                          )),
                filtereTaskNames[index]["TaskCompleteDate"] == ""
                    ? Container()
                    : FlatButton(
                        onPressed: () {},
                        child: Text(
                          DateFormat('dd MMMM yyyy  hh:mm').format(
                              DateTime.parse(
                                  filtereTaskNames[index]["TaskCompleteDate"])),
                          style: TextStyle(fontSize: 14, color: Colors.green),
                        ),
                      )
              ],
            )
          ]),
        ),
      ),
    );
  }

  AlertDialogopen() {
    return showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
                opacity: a1.value,
                child: AlertDialog(
                  backgroundColor: Colors.white,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.close_sharp,
                          color: Colors.black,
                          size: 20.0,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  content: Container(
                    height: 120,
                    child: Column(children: [
                      TextFormField(
                          controller: _txtadd,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: "Add",
                            hintText: "Enter value",
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )),
                      // ignore: deprecated_member_use
                      RaisedButton(
                        onPressed: () {
                          if (_txtadd.text == "") {
                            Fluttertoast.showToast(
                              msg: "can not be blank",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              timeInSecForIosWeb: 1,
                              textColor: Colors.red,
                            );
                          } else {
                            setState(() {
                              addTask(_txtadd.text);
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        color: Colors.blue[700],
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ]),
                  ),
                )),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: false,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Column(
            children: [],
          );
        });
  }
}
