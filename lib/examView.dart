import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

var host = 'https://insight.nexusfrontier.tech/api/v1';

class MenuView extends StatefulWidget {

  final List<dynamic> data;

  MenuView({Key key, this.data}) : super(key: key);
  
  @override
  _InnerExamView createState() => _InnerExamView();
}

class _InnerExamView extends State<MenuView> with WidgetsBindingObserver {
 
  List<dynamic> rowData =  List<dynamic>();

  TextEditingController _textFieldController = TextEditingController();

  bool _loading = false;

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? null;
  }

  Future<String> getData() async {
    var token = await getToken();
    setState(() {
      _loading = true;
    });
    http.Response response = await http.get(
      Uri.encodeFull(host + "/request/my_requests?offset=0&status=&category=&order=latest_submitted_time&direction=desc&limit=30&offset=0&status=&category=remote&order=latest_submitted_time&direction=desc"),
      headers: {
        "Accept": "application/json" ,
        'Authorization': 'Bearer $token',
      }
    );

    Map<String, dynamic> data = jsonDecode(response.body);

    List<dynamic> row = data["items"];

    setState(() {
      rowData = row;
    });

    setState(() {
      _loading = false;
    });
  }

  Future<String> requestDiscard(id) async {
    var token = await getToken();
    http.Response response = await http.post(
      Uri.encodeFull(host + '/request/$id/discard'),
      body: {
        "id": id.toString(), 
        "verdict_note": _textFieldController.text,
      },
      headers: {
        "Accept": "application/json" ,
        'Authorization': 'Bearer $token',
      }
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
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.blueAccent,
      textColor: Colors.white,
      fontSize: 25.0
    );

    getData();
  }

  Widget body() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Records"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
             Expanded(
              child: Container(
                color: Colors.white10,
                padding: EdgeInsets.all(16.0),
                child: 
                RefreshIndicator(
                  child: HomePage(rowData, (id) {
                  _textFieldController.text = "";
                  _displayDialog(context, id);
                }, _loading),
                onRefresh: getData,
              ),
            ), flex: 1),
           ],
        ),
      ),
    );
  }

   _displayDialog(BuildContext context, id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Discard remote'),
            content: Container(
              child: 
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(5.0),
                  child: TextField(
                    controller: _textFieldController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(hintText: "Discard reason"),
                  ),
                ), 
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
                      msg: "Discard reason missing",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.redAccent,
                      textColor: Colors.white,
                      fontSize: 25.0
                    );
                  } else {
                    requestDiscard(id);
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    getData();
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

  @override
  Widget build(BuildContext context) {
    return body();
    // return RefreshIndicator(
    //   child: body(),
    //   onRefresh: getData,
    // );
  }
}

class HomePage extends StatelessWidget {
  final List<dynamic> rowData;

  final Function didPressDiscard;

  final bool _loading;

  HomePage(this.rowData, this.didPressDiscard, this._loading);

  Container buttoning(context, title, { Function onClickAction }) { 
    return Container (
      child: Column(
          children: <Widget>[
            Container (
              alignment: Alignment.topLeft,
              child: Text(title, style: 
                TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ), 
              )
            ),
          ],
        )
      );
    }

  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  final texting = (title) => (
    Text(capitalize(title), style: 
      TextStyle(
        fontSize: 16,
        color: title == "Failed" ? Colors.redAccent : title == "Pending" ? Colors.yellowAccent : title == "Discarded" ? Colors.grey : title == "Approved" || title == "Passed" ? Colors.greenAccent : Colors.black,
        fontWeight: FontWeight.bold,
      )
  ));

  Row rowing(title, result) { 
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        texting(title),
        texting(result),
      ],
    );
  }

  List<Widget> times(List<dynamic> timer) {
    List<Widget> list = new List<Widget>();
    for(int i = 0; i < timer.length; i++) {
      list.add(new Row(children: <Widget>[
        texting('${timer[i]["requestTimeSession"]} | ${timer[i]["requestTime"]}')
      ]));
    }
    return list;
  }

  Container requestTime(Map<String, dynamic>object) {
    return (
        Container ( 
          child: Padding ( 
          padding: EdgeInsets.only(left: 10.0),
          child: Column (
            children: 
              times(object["requestTimes"]),
          ),
        ),
      )
    );
  }

  bool canDiscard(list) {
    if (list["requestTimes"].length > 1 || list["status"] == "Discarded") {
      return false;
    }
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    if (list["requestTimes"][0]["requestTime"] == formattedDate) {
      return true;
    }
    return false;
  }

  Container card(object) { 
    return Container (
      child: Column (
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            rowing("Category", '${object["category"]}'),
            SizedBox(height: 10),
            rowing("Compliance", '${object["compliance"]}'),
            SizedBox(height: 10),
            rowing("Status", '${object["status"]}'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                texting("Session"),
                requestTime(
                  object
                ),
              ],
            ),
            SizedBox(height: 10),
            Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[ 
                canDiscard(object) ?
                RaisedButton(
                  child: Text("Discard", style: TextStyle( color: Colors.white)),
                    onPressed: () {
                    didPressDiscard(object["id"]);
                  },
                  color: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))
                ) : SizedBox(height: 0)
              ],
            )
          ],
        )
      );
    }

  @override
  Widget build(BuildContext context) {
    return _loading ? 
      Center(child:
        Container (
          child: CircularProgressIndicator(),
          height: 80.0,
          width: 80.0,
        )
      ) 
      : ListView.builder(
      itemCount: rowData.length,
      itemBuilder: (context, pos) {
        return Padding(
          padding: EdgeInsets.all(10.0),
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: card(rowData[pos]),
            ),
          )
        );
      },
    );
  }
}
