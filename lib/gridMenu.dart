import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

var host = 'http://nexusinterviewing.ap-southeast-1.elasticbeanstalk.com';

class GridList extends StatelessWidget {

  final int id;

  GridList({Key key, @required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text("Menu"),
      ),
      body: Center(
          child: MyHomePage(idd: id),
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

  Container buttoning(String title, { Function onClickAction }) { 
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
          child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Montserrat', fontSize: 20.0)),
        ),
        )
      );
    }
  

  Widget body() {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
        color: Colors.white30,
        child: Center( 
          child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.all(4.0),
              mainAxisSpacing: 40.0,
              crossAxisSpacing: 40.0,
              children: <String>[
                'http://www.for-example.org/img/main/forexamplelogo.png',
                'http://www.for-example.org/img/main/forexamplelogo.png',
                'http://www.for-example.org/img/main/forexamplelogo.png',
                'http://www.for-example.org/img/main/forexamplelogo.png',
              ].map((String url) {
                return GridTile(
                    child: buttoning(url, onClickAction: null));
              }).toList()),
        ),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
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
