import 'package:flutter/material.dart';
import '../../tools/Circle.dart';
import '../../res/treeRes.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double treeWidth = 200.0;
  double treeHeight = 300.0;
  double widthPrc = 2.0;
  double heightPrc = 3.0;

  List<Widget> _getData() {
    var tempList = listData.map((value) {
      return CircleAnimated(value["dx"], value["dy"], value["begincolor"],
          value["endcolor"], value["time"]);
    });
    return tempList.toList();
  }

  @override
  Widget build(BuildContext context) {
    double treeWidth = 200.0;
    double treeHeight = 300.0;

    this._getData();
    return Container(
      width: treeWidth,
      height: treeHeight,
      child: Column(
          children:this._getData(),
          ),
    );
  }
}
