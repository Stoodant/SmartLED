import 'package:flutter/material.dart';
import '../../res/control.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

class CategoryPage extends StatefulWidget {
  CategoryPage({Key key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  void testCP() {
    const timeout = const Duration(seconds: 3); //延迟3秒
    Timer(timeout, () {
      //在这里调用
      //实例化
      customPacket cp = customPacket();

      //测试test函数
      print("test cp's test!!!");
      cp.test();

      //测试getMemoryInfo函数
      print("test cp's getMemoryInfo!!!");
      cp.getMemoryInfo();

      //测试testLED函数
      print("test cp's testLED!!!");
      cp.testLED();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: FloatingActionButton(
              onPressed: () => testCP(),
              heroTag: "totest",
              child: Text("Test"),
            ),
            width: 50,
            height: 50,
          )
        ]);
  }
}
