
import 'package:flutter/material.dart';
import '../../tools/Circle.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../res/treeRes.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage>
    with SingleTickerProviderStateMixin {
  bool type = false;
  List<bool> typeList = [];
  List<Color> colorList = [];

  void getTypeAndColor() {
    for (var i = 0; i < showData.length; i++) {
      typeList.add(false);
      colorList.add(Colors.black);
    }
  }

  Color currentColor = Colors.black;
  Color pickerColor = Color(0xff443a49);

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

    getTypeAndColor();
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
                List<bool> flagList = [];
                List turnColList = [];
                for (var i = 0; i < showData.length; i++) {
                  flagList.add(false);
                  turnColList.add(ColorTween(
                          begin: flagList[i] ? currentColor : colorList[i],
                          end: typeList[i]
                              ? Colors.black
                              : (flagList[i] ? currentColor : colorList[i]))
                      .animate(_controller));
                }

                List<Widget> showWidget = [];
                for (var i = 0; i < showData.length; i++) {
                  //print(showData[i]["top"]);
                  showWidget.add(Positioned(
                    child: GestureDetector(
                      onTapDown: (event) {
                        flagList[i] = true;
                        typeList[i] = type;
                        colorList[i] = currentColor;
                      },
                      onPanDown: (evnt) {
                        flagList[i] = true;
                        typeList[i] = type;
                        colorList[i] = currentColor;
                      },
                      child: CustomPaint(
                          painter:
                              CirclePainter(0.0, 0.0, turnColList[i].value),
                          size: Size(16, 16)),
                    ),
                    top: showData[i]["top"],
                    left: showData[i]["left"],
                  ));
                }
                return GestureDetector(
                  child: Container(
                    child: Stack(
                      children: showWidget,
                    ),
                    width: 400,
                    height: 435,
                  ),
                  onTapDown: (e) {
                    print(e.localPosition);
                  },
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
            margin: EdgeInsets.only(left: 200),
          )
        ],
      ),
    );
  }
}
