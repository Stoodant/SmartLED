import 'package:flutter/material.dart';
import '../../tools/Circle.dart';
import '../../res/treeRes.dart';
import '../tabs/setting.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _treeWidth = 200.0; //矩形宽度
  double _treeHeight = 300.0; //矩形高度

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

  @override
  Widget build(BuildContext context) {
    double treeWidth = 180.0;
    double treeHeight = 300.0;

    //this._getData();

    List<Widget> conList = [];
    for (var i = 0; i < countData.length; i++) {
      conList.add(Container(
        width: treeWidth,
        height: treeHeight,
        child: Column(
          children: this._getData(countData[i]),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),

            ///圆角
            border: Border.all(color: Colors.blueAccent, width: 1)

            ///边框颜色、宽
            ),
      ));
    }

    conList.add(Container(
      width: treeWidth,
      height: treeHeight,
      child: Column(
        children: <Widget>[
          Container(
            child: FloatingActionButton(
              onPressed: ()=>Navigator.of(context).pushNamed("draw"),
              heroTag: "home",
              child: Text("新建"),
            ),
            width: 60,
            height: 60,
            margin: EdgeInsets.only(top:100),
          )
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        ///圆角
        border: Border.all(color: Colors.blueAccent, width: 1)
        ///边框颜色、宽
        ),
    ));

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: conList,
    );
  }
}
