import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './inputExamView.dart';

var host = 'http://nexusinterviewing.ap-southeast-1.elasticbeanstalk.com';

class SecRoute extends StatelessWidget {

  final String title;

  SecRoute({Key key, @required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: Center(
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  List<dynamic> test =  List<dynamic>();

  Future<String> getData() async {
    http.Response response = await http.get(
      Uri.encodeFull(host + "/list/getList"),
      headers: {
       "Accept": "application/json" 
      }
    );

    List<dynamic> data = jsonDecode(response.body);
    setState(() => {
        test = data
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
    return RefreshIndicator(
      child: HomePage(test),
      onRefresh: getData,
    );
  }
  
}

class HomePage extends StatelessWidget {
  final List<dynamic> notes;

  HomePage(this.notes);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, pos) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(child: 
           Card(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(notes[pos]["name"], style: 
                    TextStyle(
                      fontSize: 18.0,
                      height: 1.6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(notes[pos]["description"], style: 
                    TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          onTap: (){
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InputExamView(id: notes[pos]["id"])),
            );
          },
          )
        );
      },
    );
  }
}