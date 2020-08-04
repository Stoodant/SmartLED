import 'package:flutter/material.dart';
import 'package:flutter_app/pages/edit.dart';
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
  List<String> _contents = [];
  List _nameList = [];

  List<Widget> _getData(List list) {
    double _widthOffset = _treeWidth * 0.5;
    List<Widget> res = [];
    for (var i = 1; i < list.length; i++) {
      res.add(CircleAnimated(
          list[i]["dx"] * _treeWidth - _widthOffset,
          list[i]["dy"] * _treeHeight,
          list[i]["begincolor"],
          list[i]["endcolor"],
          list[i]["time"],
          list[i]["type"],
          list[i]["pwm"]));
    }

    res.add(Container(
      child: Text(list[0]["name"],style: TextStyle(fontSize: 16)),
      margin: EdgeInsets.only(top:260),
    ));
    return res;
  }

  //获取文件函数
  Future<File> _getLocalFile(String str) async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/$str.json');
  }

  //从字符串中获取颜色的十六进制，并返回一个相应Color对象
  Color getColor(String str) {
    String objStr = str.substring(str.indexOf("(") + 1, str.indexOf(")"));
    return Color(int.parse(objStr));
  }

  //读取相应的文件内容，并返回一个json字符串，要注意删除空的元素
  Future<String> _read(String str, double treeWidth, double treeHeight) async {
    if (str.isNotEmpty) {
      try {
        File file = await _getLocalFile(str);
        String tmp = await file.readAsString();
        return tmp;
      } on FileSystemException {
        print('no data');
      }
    }
  }

  //从nameData文件中获取总够有多少信息文件，并返回一个list
  Future<List> _getName() async {
    File file = await _getLocalFile("nameData");
    String tmp = await file.readAsString();
    List<String> res = tmp.split("@");
    for (var i = 0; i < res.length; i++) {
      if (res[i] == "") {
        res.remove(res[i]);
      }
    }
    return res;
  }

  //界面初始化
  @override
  void initState() {
    // TODO: implement initState
    //首先先从nameData文件中获取总共有多少文件

    setState(() {});

    _getName().then((value) {
      print("getName success!!!!!!!!!!!!!");
      _nameList = value;
      print("this is nameList");
      print(_nameList);
      print(_nameList.length);
      print("over------------");
      //从nameList中循环获取相应的配置信息
      for (var i = 0; i < _nameList.length; i++) {
        _read(_nameList[i], _treeWidth, _treeHeight).then((value) {
          if (value == null) {
            print("get null value!!");
          } else {
            print("nameList success!!!!!!!!!!!!!");
            _contents.add(value);
          }
        });
      }
      setState(() {});
    });

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
        child: Column(children: this._getData(countData[i])),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: Colors.blueAccent, width: 1)),
      ));
    }

    //处理用户生成的信息文件
    if (_contents.length > 0) {
      for (var i = 0; i < _contents.length; i++) {
        //print(contents[i] is String);
        if (_contents[i].length > 0) {
          List str = json.decode(_contents[i]);
          List<Widget> tmp = [];
          double _widthOffset = _treeWidth * 0.5;
          for (var i = 0; i < str.length; i++) {
            // print("this is dx!!!!!!!!!!!!!!!");
            // print(str[i]["dx"] * _treeWidth - _widthOffset);
            tmp.add(CircleAnimated(
                str[i]["dx"] * _treeWidth - _widthOffset,
                str[i]["dy"] * _treeHeight,
                getColor(str[i]["begincolor"]),
                getColor(str[i]["endcolor"]),
                str[i]["time"],
                str[i]["type"],
                str[i]["pwm"]));
          }

          tmp.add(Container(
            child: Text(str[i]["name"],style: TextStyle(fontSize: 16)),
            margin: EdgeInsets.only(top:260),
          ));

          conList.add(GestureDetector(
            child: Container(
              width: treeWidth,
              height: treeHeight,
              child: Column(
                children: tmp,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: Colors.blueAccent, width: 1)),
            ),
            onTap: () {
              // print("this is tmp!!!!!!!!!!!!!!");
              //print(str);
              //print(_nameList[i]);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => editPage(str, _nameList[i])));
            },
          ));
        } else
          print("contents is NULL!!!!!!!!!!!");
      }
    }

    conList.add(Container(
      width: treeWidth,
      height: treeHeight,
      child: Column(
        children: <Widget>[
          Container(
            child: FloatingActionButton(
              onPressed: () {
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
