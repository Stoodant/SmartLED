import 'package:flutter/material.dart';
import '../../tools/Circle.dart';
import '../../res/treeRes.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _treeWidth = 200.0;//矩形宽度
  double _treeHeight = 300.0;//矩形高度

  List<Widget> _getData() {
    double _widthOffset = _treeWidth * 0.5;
    var tempList = listData.map((value) {
      return CircleAnimated(
          value["dx"] * _treeWidth - _widthOffset,
          value["dy"] * _treeHeight,
          value["begincolor"],
          value["endcolor"],
          value["time"],
          value["type"],
          value["pwm"]
      );
    });
    return tempList.toList();
  }

  @override
  Widget build(BuildContext context) {
    double treeWidth = 200.0;
    double treeHeight = 300.0;

    //this._getData();
    return Container(
      width: treeWidth,
      height: treeHeight,
      child: Column(
          children:this._getData(),
          ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),///圆角
          border: Border.all(color: Colors.blueAccent,width: 1)///边框颜色、宽
      ),
    );
  }
}
