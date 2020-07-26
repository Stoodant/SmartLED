import 'dart:ffi';

import 'package:flutter/material.dart';
import '../../tools/Circle.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with SingleTickerProviderStateMixin {
  bool type = false;
  bool type1 = false;
  bool type2 = false;
  bool type3 = false;
  bool type4 = false;
  bool type5 = false;

  Color currentColor = Colors.black;
  Color pickerColor = Color(0xff443a49);
  Color tmpColor1 = Colors.black;
  Color tmpColor2 = Colors.black;
  Color tmpColor3 = Colors.black;
  Color tmpColor4 = Colors.black;
  Color tmpColor5 = Colors.black;

  void changeColor(Color color) => setState(() {
        pickerColor = color;
        currentColor = pickerColor;
      });
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    _controller.repeat(reverse: true);

    _controller.addStatusListener((status) {
      //print(currentColor.toString() + "        " + _controller.value.toString());
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double treeWidth = 400.0;
    //double treeHeight = 500.0;
    return Container(
      width: treeWidth,
      // height: treeHeight,
      child: Column(
        children: <Widget>[
          AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget child) {
                //flag为是否点击标志
                bool _flag1 = false;
                bool _flag2 = false;
                bool _flag3 = false;
                bool _flag4 = false;
                bool _flag5 = false;

                var _turnCol1 = ColorTween(
                        begin: _flag1 ? currentColor : tmpColor1,
                        end: type1
                            ? Colors.black
                            : (_flag1 ? currentColor : tmpColor1))
                    .animate(_controller);
                var _turnCol2 = ColorTween(
                        begin: _flag2 ? currentColor : tmpColor2,
                        end: type2
                            ? Colors.black
                            : (_flag2 ? currentColor : tmpColor2))
                    .animate(_controller);
                var _turnCol3 = ColorTween(
                        begin: _flag3 ? currentColor : tmpColor3,
                        end: type3
                            ? Colors.black
                            : (_flag3 ? currentColor : tmpColor3))
                    .animate(_controller);
                var _turnCol4 = ColorTween(
                        begin: _flag4 ? currentColor : tmpColor4,
                        end: type4
                            ? Colors.black
                            : (_flag4 ? currentColor : tmpColor4))
                    .animate(_controller);
                var _turnCol5 = ColorTween(
                        begin: _flag5 ? currentColor : tmpColor5,
                        end: type5
                            ? Colors.black
                            : (_flag5 ? currentColor : tmpColor5))
                    .animate(_controller);
                return Container(
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: GestureDetector(
                          onTap: () {
                            _flag1 = true;
                            type1 = type;
                            tmpColor1 = currentColor;
                            print(type);
                            print(type1);
                            print("点击111111111");
                          },
                          onPanDown: (evnt) {
                            _flag1 = true;
                            type1 = type;
                            tmpColor1 = currentColor;
                            print("滑过111111111");
                          },
                          child: CustomPaint(
                              painter: CirclePainter(0.0, 0.0, _turnCol1.value),
                              size: Size(16, 16)),
                        ),
                        top: 100,
                        left: 100,
                      ),
                      Positioned(
                        child: GestureDetector(
                          onTap: () {
                            _flag2 = true;
                            type2 = type;
                            tmpColor2 = currentColor;
                            print("点击222222222");
                          },
                          onPanDown: (evnt) {
                            _flag2 = true;
                            type2 = type;
                            tmpColor2 = currentColor;
                            print("滑过222222222");
                          },
                          child: CustomPaint(
                              painter: CirclePainter(0.0, 0.0, _turnCol2.value),
                              size: Size(16, 16)),
                        ),
                        top: 80,
                        left: 120,
                      ),
                      Positioned(
                        child: GestureDetector(
                          onTap: () {
                            _flag3 = true;
                            type3 = type;
                            tmpColor3 = currentColor;
                            print("点击333333333");
                          },
                          onPanDown: (evnt) {
                            _flag3 = true;
                            type3 = type;
                            tmpColor3 = currentColor;
                            print("滑过333333333333");
                          },
                          child: CustomPaint(
                              painter: CirclePainter(0.0, 0.0, _turnCol3.value),
                              size: Size(16, 16)),
                        ),
                        top: 80,
                        left: 160,
                      ),
                      Positioned(
                        child: GestureDetector(
                          onTap: () {
                            _flag4 = true;
                            type4 = type;
                            tmpColor4 = currentColor;
                            print("点击444444444");
                          },
                          onPanDown: (evnt) {
                            _flag4 = true;
                            type4 = type;
                            tmpColor4 = currentColor;
                            print("滑过444444444");
                          },
                          child: CustomPaint(
                              painter: CirclePainter(0.0, 0.0, _turnCol4.value),
                              size: Size(16, 16)),
                        ),
                        top: 120,
                        left: 120,
                      ),
                      Positioned(
                        child: GestureDetector(
                          onTap: () {
                            _flag5 = true;
                            type5 = type;
                            tmpColor5 = currentColor;
                            print("点击55555555555");
                          },
                          onPanDown: (evnt) {
                            _flag5 = true;
                            type5 = type;
                            tmpColor5 = currentColor;
                            print("滑过555555555");
                          },
                          child: CustomPaint(
                              painter: CirclePainter(0.0, 0.0, _turnCol5.value),
                              size: Size(16, 16)),
                        ),
                        top: 120,
                        left: 160,
                      ),
                    ],
                  ),
                  width: 400,
                  height: 435,
                );
              }),
          ColorPicker(
            //颜色选择器
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            showLabel: false,
            pickerAreaHeightPercent: 0.2,
          ),
          Container(
            child: FloatingActionButton(
              onPressed: () => type = !type,
            ),
            width: 50,
            height: 50,
            margin: EdgeInsets.only(left:200),
          )
        ],
      ),
    );
  }
}
