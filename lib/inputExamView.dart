import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quick_remote/examView.dart';
import 'package:http/http.dart' as http;

var host = 'http://nexusinterviewing.ap-southeast-1.elasticbeanstalk.com';

class InputExamView extends StatelessWidget {

  final int id;

  InputExamView({Key key, @required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text("Start"),
      ),
      body: SingleChildScrollView (
        child: Center(
          child: MyHomePage(idd: id),
        )
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int idd;

  MyHomePage({Key key, @required this.idd}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  List<dynamic> test =  List<dynamic>();

  final emailField = TextField(
            obscureText: false,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: "Email",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
          );

  final passwordField = TextField(
            obscureText: true,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                hintText: "Password",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
          );
  
  Container buttoning({ Function onClickAction }) { 
   return Container (
     child:  Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          onClickAction();
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)),
      ),
      )
    );
  }
  
  static final TextEditingController _textController = TextEditingController();

  Future<String> getData() async {
    Map<String, dynamic> body = {"id": widget.idd.toString()};
    http.Response response = await http.post(
      Uri.encodeFull(host + "/list/getListById"),
      body: body,
      headers: {
       "Accept": "application/json" 
      },
      encoding: Encoding.getByName('utf-8'),
    );

    List<dynamic> data = jsonDecode(response.body);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MenuView(data: data)
    ));
  }

  Widget body() {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container (
            child: Image.asset(
              "images/nexusfrontier-logo.png"
            ),
            color: Colors.grey,
            height: MediaQuery.of(context).size.height * 0.25,
          ),
          SizedBox(height: 35.0),
          emailField,
          SizedBox(height: 35.0),
          passwordField,
          SizedBox(height: 35.0),
          buttoning(
            onClickAction: () => getData()
          )
        ],
      )
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _textController.text = "";
    // getData();
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
  }
}
