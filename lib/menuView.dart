import 'package:flutter/material.dart';
import './detailView.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 
List<String> notes = [
    "Gói câu hỏi",
    "Lịch sử",
    "Đồng bộ",
    "Cài đặt",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(child: 
              Image.asset(
                "images/nexusfrontier-logo.png"
              ),
              height: MediaQuery.of(context).size.height * 0.25,
              color: Colors.grey,
            ),
             Expanded(
              child: Container(
                color: Colors.white10,
                padding: EdgeInsets.all(16.0),
                child: HomePage(notes)
            ), flex: 1),
           ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<String> notes;

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
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Text(notes[pos], style: 
                TextStyle(
                  fontSize: 18.0,
                  height: 1.6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          onTap: (){
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecRoute(title: notes[pos])),
            );
          },
          )
        );
      },
    );
  }
}
