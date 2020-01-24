import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:quick_remote/examView.dart';
import 'package:quick_remote/remoteView.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

var host = 'https://insight.nexusfrontier.tech/api/v1';

class Login extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: SingleChildScrollView (
        child: Center(
          child: MyHomePage(),
        )
      ),
      //  floatingActionButton: new FloatingActionButton(
      //   elevation: 1.0,
      //   child: new Icon(Icons.check),
      //   backgroundColor: new Color(0xFFE57373),
      //   onPressed: (){

      //   }
      // ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  List<dynamic> test =  List<dynamic>();

  String email = "";

  String password = "";

  bool isLoading = false;

  String errorMessage = "";

  static final TextEditingController _textController = TextEditingController();

  Widget emailField() {
     return TextField(
      obscureText: false,
      onChanged: (text) {
        setState(() {
          email = text;
          errorMessage = "";
        });
      },
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Email",
          border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
  }

  Widget passwordField() {
     return TextField(
      obscureText: true,
      onChanged: (text) {
        setState(() {
          password = text;
          errorMessage = "";
        });
      },
      style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
  }
  
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

  Future<void> setToken(token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);

  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") ?? null;
  }

  Future<dynamic> didRequestLogin() async {
    Map<String, dynamic> body = {"email": this.email, 
                                "password": this.password,
                                "client_id": "2",
                                "client_secret": "tCNb7eYXDM8SMQjjTF7Srl6IZsDMgSZOWKWqPYXl"};
    http.Response response = await http.post(
      Uri.encodeFull(host + "/signin"),
      body: body,
      headers: {
       "Accept": "application/json" 
      },
      encoding: Encoding.getByName('utf-8'),
    );

    Map<String, dynamic> dataToken = jsonDecode(response.body);

    if (dataToken.containsKey("isSuccess") && !dataToken["isSuccess"]) {
      List<dynamic> params = dataToken["invalidParams"];
      setState(() {
        errorMessage = params.length != 0 ? dataToken["invalidParams"][0]["message"] : dataToken["detail"];
      });
      return;
    }

    setToken(dataToken["accessToken"]);

    didGoToMenu();
  }

  void _didRequest() {
    setState(() {
      isLoading = true;
    });

    didRequestLogin().then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void didGoToMenu() {
     Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RemoteView(title: "Quick remote"), fullscreenDialog: true
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
          SizedBox(height: 25.0),
          Text(errorMessage, style: 
            TextStyle(
              color: Colors.red,
              fontSize: 18,
            )
          ),
          SizedBox(height: 25.0),
          emailField(),
          SizedBox(height: 35.0),
          passwordField(),
          SizedBox(height: 35.0),
          isLoading ? 
          Center ( child: CircularProgressIndicator() ) 
            : 
          buttoning(
            onClickAction: () => _didRequest()
          )
        ],
      )
    );
  }

  @override
  initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _textController.text = "";
    checkForAuthen();
  }

  void checkForAuthen() async {
    var token = await getToken();
    if (token != null) {
      didGoToMenu();
    }
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
