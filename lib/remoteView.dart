import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:progress_hud/progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:quick_remote/examView.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

var host = 'https://insight.nexusfrontier.tech/api/v1';

class RemoteView extends StatelessWidget {

  final String title;

  RemoteView({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => Future.value(false),
        child: Scaffold(
      appBar: AppBar(
        title: Text(this.title),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Remote(),
      ),
    ))
    ;
  }
}

class Remote extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Remote> with WidgetsBindingObserver {

  FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<dynamic> test =  List<dynamic>();

  String session = "";

  Map uInfo = {};

  ProgressHUD _progressHUD;

  bool _loading = false;

  initializeNotifications() async {
    var initializeAndroid = AndroidInitializationSettings('ic_launcher');
    var initializeIOS = IOSInitializationSettings();
    var initSettings = InitializationSettings(initializeAndroid, initializeIOS);
    await localNotificationsPlugin.initialize(initSettings);
  }

  Future singleNotification(
      DateTime datetime, String message, String subtext, int hashcode,
      {String sound}) async {
    var androidChannel = AndroidNotificationDetails(
      'channel-id',
      'channel-name',
      'channel-description',
      importance: Importance.Max,
      priority: Priority.Max,
    );

    var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(androidChannel, iosChannel);
    localNotificationsPlugin.schedule(
        hashcode, message, subtext, datetime, platformChannel,
        payload: hashcode.toString());
  }

  List<String> options = [
    "Due to health issue, i'm working remotely {{}}. Please be informed.",
    "Due to personal plan, i'm working remotely {{}}. Please be informed.",
    "I'd like to work remotely {{}}, please be informed.",
    "Due to weather issue, i'd would like to work remotely {{}}. Thanks.",
    "I'd would like to work remotely {{}} due to bike problem.",
    "I have a bad headache so i'll work remotely {{}}, please be noted.",
    "I got a little bit sick so i'm working remotely {{}}, please kindly noted.",
    "I have personal issue so i'd like to work remotely {{}}, sorry for the inconvinience.",
  ];
  TextEditingController _textFieldController = TextEditingController();

  String todayDate() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    return formattedDate;
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? null;
  }

  removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove("token");
  }

   Future<String> remote() async {
    var token = await getToken();
    setState(() {
      _loading = true;
    });
    http.Response response = await http.post(
      Uri.encodeFull(host + "/request/remote"),
      body: json.encode({"reason": _textFieldController.text, 
                                "request_time": [{
                                  "date": todayDate(),
                                  "requestTime": todayDate(),
                                  "requestTimeSession": session,
                                  "session": session,
                                  "session_value": session == "day" ? "1" : "0.5",
                                }]}),
      headers: {
        "Accept": "application/json" ,
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      },
    );

    Map<String, dynamic> dataToken = jsonDecode(response.body);

    String errorMessage = "";
    if (dataToken.containsKey("isSuccess") && !dataToken["isSuccess"]) {
        List<dynamic> params = dataToken["invalidParams"];
        errorMessage = params.length != 0 ? dataToken["invalidParams"][0]["message"] : dataToken["detail"];
    } 
    if (dataToken.containsKey("isSuccess") && dataToken["isSuccess"]) {
        errorMessage = dataToken["detail"];
    }

    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
      fontSize: 25.0
    );

    setState(() {
      _loading = false;
    });
  }

  Future<String> getProfile() async {
    var token = await getToken();
    http.Response response = await http.get(
      Uri.encodeFull(host + "/my-profile"),
      headers: {
        "Accept": "application/json" ,
        'Authorization': 'Bearer $token',
      }
    );

    Map<String, dynamic> data = jsonDecode(response.body);

    setState(() {
      uInfo = data;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    initializeNotifications();
    super.initState();
    _textFieldController.text = "";
    _progressHUD = new ProgressHUD(
      backgroundColor: Colors.black12,
      color: Colors.white,
      containerColor: Colors.blue,
      borderRadius: 5.0,
      loading: false,
      text: 'Loading...',
    );
    getProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
  }

  List<Widget> makeRadios() {
    List<Widget> list = new List<Widget>();

    for(int i = 0; i < options.length; i++) {
      list.add(
        optioning(options[i].replaceAll(new RegExp(r'{{}}'), session == "day" ? "to" +  session : "this " + session), 
            onClickAction: () => _textFieldController.text = options[i].replaceAll(new RegExp(r'{{}}'), session == "day" ? "to" + session : "this " + session),
          )
      );
    }
    
    return list;
  }

  _confirmDialog(BuildContext context, { Function onClickAction }) async {
    return showDialog (
        context: context,
        builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.all(0),
          title: Text(""),
          content: Text("Out?"),
          actions: <Widget>[
            FlatButton(
              child: Text('Ờ'),
              onPressed: 
        //       () async {
        //   DateTime now = DateTime.now().toUtc().add(
        //         Duration(seconds: 15),
        //       );
        //   await singleNotification(
        //     now,
        //     "Notification",
        //     "This is a notification",
        //     98123871,
        //   );
        // }
              () {
                onClickAction();
              },
            ),
          ],
        );
      }
    );
  }

  _displayDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Remote request session: \n$session | ${todayDate()}'),
            content: Container(
              // color: Colors.red,
              child: Column (
              children: <Widget> [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: makeRadios(),
                    )
                  ),
                  // flex: 7,
                ),
                //  Expanded(
                //   child: 
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(5.0),
                    child: TextField(
                      controller: _textFieldController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      decoration: InputDecoration(hintText: "Remote reason"),
                    ),
                  ), 
                  // flex: 3
                  // ),
                ]
            )
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('SUBMIT'),
                onPressed: () {
                  if (_textFieldController.text.replaceAll(new RegExp(r' '), '').length == 0) {
                    Fluttertoast.showToast(
                      msg: "Remote reason missing",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.redAccent,
                      textColor: Colors.white,
                      fontSize: 25.0
                    );
                  } else {
                    remote();
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
  }

Container optioning(String title, { Function onClickAction }) { 
   return Container (
     child: Padding ( 
      padding: EdgeInsets.all(5.0),
       child:  Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(10.0),
        color: Color(0xff01A0C7),
        child: MaterialButton (
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(5.0),
          onPressed: () {
            onClickAction();
          },
          child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 15.0)),
        ),
        )
      )
    );
  }

  Container buttoning(String title, { Function onClickAction }) { 
   return Container (
     child: Padding ( 
      padding: EdgeInsets.all(15.0),
       child:  Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Color(0xff01A0C7),
        child: MaterialButton (
          minWidth: MediaQuery.of(context).size.width,
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          onPressed: () {
            onClickAction();
          },
          child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 24.0)),
        ),
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column (
      children: <Widget>[
        Expanded(
          child: Container (
              // alignment: Alignment.topRight,
              // padding: EdgeInsets.all(10),
              child: Row( 
                children: <Widget>[ 
                  Spacer(),
                  Text(uInfo.containsKey("informations") ? '${uInfo["informations"]["company_name"]}, welcome!' : "", style: 
                    TextStyle(
                      fontSize: 22,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.bold,
                    ), 
                  ),
                  IconButton(
                    icon: Image.asset('images/power.png'),
                    iconSize: 20,
                    onPressed: () {
                       _confirmDialog(context,
                        onClickAction: () {
                        removeToken();
                        Navigator.of(context, rootNavigator: false).pop();
                        Navigator.of(context, rootNavigator: false).pop();
                        }
                      );
                    },
                  ),
                ]
              )
            ),
          flex: 1),
        Expanded(
          child: Center (
          child: SingleChildScrollView (
                    child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _loading ? 
          SizedBox (
            child: CircularProgressIndicator(),
            height: 80.0,
            width: 80.0,
          ) 
            :
          IconButton(
            icon: Image.asset(
              "images/remote.png",
              height: 150,
              width: 150,
            ),
            iconSize: 200,
            onPressed: () {
              //   _confirmDialog(context,
              //   onClickAction: () {
              //   removeToken();
              //   Navigator.of(context, rootNavigator: false).pop();
              //   Navigator.of(context, rootNavigator: false).pop();
              //   }
              // );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuView(data: [])
              ));
            },
          ),
          SizedBox(height: 20),
          buttoning("1/2 Morning", 
            onClickAction: () { 
              setState(() {
                session = "morning";
              });
              _textFieldController.text = options[0].replaceAll(new RegExp(r'{{}}'), session == "day" ? "to" + session : "this " + session);
              _displayDialog(context);
            },
          ),
          buttoning("1/2 Noon", 
            onClickAction: () {
              setState(() {
                session = "afternoon";
              });
              _textFieldController.text = options[0].replaceAll(new RegExp(r'{{}}'), session == "day" ? "to" + session : "this " + session);
              _displayDialog(context);
            }
          ),
          buttoning("1/2 + 1/2", 
            onClickAction: () {
              setState(() {
                session = "day";
              });
              _textFieldController.text = options[0].replaceAll(new RegExp(r'{{}}'), session == "day" ? "to" +  session : "this " + session);
              _displayDialog(context);
            },
          ),
        ],
      ),)
    ), flex: 8),
      Expanded(
        child: Container (
            alignment: Alignment.topLeft,
            padding: EdgeInsets.all(10),
            child: Row (
              children: <Widget> [
              FlatButton(
                child: Text('powered_by_',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                    // decoration: TextDecoration.underline,
                  ),
                ),
                onPressed: null,
                //  () {
                //   _confirmDialog(context,
                //     onClickAction: () {
                //       // Navigator.pop()
                //       // Navigator.pop(context)
                //       removeToken();
                //       Navigator.of(context, rootNavigator: false).pop();
                //       Navigator.of(context, rootNavigator: false).pop();
                //     }
                //   );
                // },
              ), Text('Flutter',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  // decoration: TextDecoration.underline,
                ),
              ) 
            ])
          ),
        flex: 1)
      ]
    );
  }
}