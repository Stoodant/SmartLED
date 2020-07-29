import 'package:flutter/material.dart';
import '../../tools/Circle.dart';
import '../../res/treeRes.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _treeWidth = 200.0; //矩形宽度
  double _treeHeight = 300.0; //矩形高度
  String contents = "";

  List<Widget> _getData(List list) {
    double _widthOffset = _treeWidth * 0.5;

    var tempList = list.map((value) {
      return CircleAnimated(
          value["dx"] * _treeWidth - _widthOffset,
          value["dy"] * _treeHeight,
          value["begincolor"],
          value["endcolor"],
          value["time"],
          value["type"],
          value["pwm"]);
    });
    return tempList.toList();
  }

  Future<File> _getLocalFile(String str) async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    //print(dir);
    return new File('$dir/$str.json');
  }

  Color getColor(String str) {
    String objStr = str.substring(str.indexOf("(") + 1, str.indexOf(")"));
    return Color(int.parse(objStr));
  }

  Future<String> _read(double treeWidth, double treeHeight) async {
    try {
      File file = await _getLocalFile("test");
      String tmp = await file.readAsString();
      return tmp;
    } on FileSystemException {
      print('no data');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _read(_treeWidth, _treeHeight)
        .then((value) => setState(() => contents = value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double treeWidth = 180.0;
    double treeHeight = 300.0;

    List<Widget> conList = [];
    //print(countData);
    for (var i = 0; i < countData.length; i++) {
      conList.add(Container(
        width: treeWidth,
        height: treeHeight,
        child: Column(
          children: this._getData(countData[i]),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.blueAccent, width: 1)),
      ));
    }
    //_read(conList, treeWidth, treeHeight);
    if (contents.length > 0) {
      List str = json.decode(contents);
      List<Widget> tmp = [];
      double _widthOffset = _treeWidth * 0.5;
      for (var i = 0; i < str.length; i++) {
        tmp.add(CircleAnimated(
            str[i]["dx"] * _treeWidth - _widthOffset,
            str[i]["dy"] * _treeHeight,
            getColor(str[i]["begincolor"]),
            getColor(str[i]["endcolor"]),
            str[i]["time"],
            str[i]["type"],
            str[i]["pwm"]));
      }
      conList.add(Container(
        width: treeWidth,
        height: treeHeight,
        child: Column(
          children: tmp,
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.blueAccent, width: 1)),
      ));
    } else
      print("contents is NULL!!!!!!!!!!!");

    conList.add(Container(
      width: treeWidth,
      height: treeHeight,
      child: Column(
        children: <Widget>[
          Container(
            child: FloatingActionButton(
              onPressed: () {
                //_read();
                Navigator.of(context).pushNamed("draw");
              },
              heroTag: "home",
              child: Text("新建"),
            ),
            width: 60,
            height: 60,
            margin: EdgeInsets.only(top: 100),
          )
        ],
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.blueAccent, width: 1)),
    ));

    return ListView(
      children: <Widget>[
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: conList,
        )
      ],
    );
  }
}
