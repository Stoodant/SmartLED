import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../tools/Circle.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../res/treeRes.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class drawPage extends StatefulWidget {
  drawPage({Key key}) : super(key: key);

  @override
  _drawPageState createState() => _drawPageState();
}

class _drawPageState extends State<drawPage>
    with SingleTickerProviderStateMixin {
  //type为判断是否按下闪烁按钮
  bool type = false;
  //typeList为所有LED灯闪烁标志
  List<bool> typeList = [];
  //colorList为所有LED灯的颜色控制，一个LED灯对应一个
  List<Color> colorList = [];
  //将要写入文件的值
  List res = [];

  //该函数为初始化typeList和colorList的数量，默认初始化为false和黑色
  void getTypeAndColor() {
    for (var i = 0; i < showData.length; i++) {
      typeList.add(false);
      colorList.add(Colors.black);
    }
  }

  //pickColor为颜色选择器所选择的颜色，currentColor为选择器需要的参数
  Color currentColor = Colors.black;
  Color pickerColor = Color(0xff443a49);

  //颜色选择器改变颜色所需要调用的函数，将currentColor的赋值也放在这，可以不需要按钮就能改变颜色
  void changeColor(Color color) => setState(() {
        pickerColor = color;
        currentColor = pickerColor;
      });
  //动画控制器
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    _controller.repeat(reverse: true);

    //初始化外部参数
    getTypeAndColor();
    super.initState();
  }

  Future<File> _getLocalFile(String str) async {
    // get the path to the document directory.
    String dir = (await getApplicationDocumentsDirectory()).path;
    print(dir);
    return new File('$dir/$str.json');
  }

  String getRandom() {
    String alphabet = 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
    int strlenght = 10;

    /// 生成的字符串固定长度
    String left = '';
    for (var i = 0; i < strlenght; i++) {
      //    right = right + (min + (Random().nextInt(max - min))).toString();
      left = left + alphabet[Random().nextInt(alphabet.length)];
    }
    return left;
  }

  void _save(String str) async {
    for (var i = 0; i < showData.length; i++) {
      res.add({
        "dx": showData[i]["left"],
        "dy": showData[i]["top"],
        "begincolor": colorList[i].toString(),
        "endcolor": colorList[i].toString(),
        "time": typeList[i] ? 500 : 1000,
        "type": typeList[i] ? 2 : 1,
        "pwm": typeList[i] ? 0.2 : 1.0,
      });
    }
    String result = json.encode(res);
    File file = await _getLocalFile(str);
    file.writeAsString(result);

    File tmp = await _getLocalFile("nameData");
    tmp.writeAsString(str + "@", mode: FileMode.append);

    setState(() {
      res = [];
    });
    //print(result is String);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _treeWidth = 300.0; //矩形宽度
    double _treeHeight = 450.0; //矩形高度
    return Scaffold(
        appBar: AppBar(
          title: Text("draw LED"),
        ),
        body: Container(
          width: 400.0,
          // height: treeHeight,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget child) {
                    //flagList为是否点击标志
                    List<bool> flagList = [];
                    //turnColList为颜色控制器
                    List turnColList = [];
                    //通过遍历treeRes文件重的showData列表来初始化所以LED的颜色控制器
                    for (var i = 0; i < showData.length; i++) {
                      flagList.add(false);
                      turnColList.add(ColorTween(
                              //通过flag来判断是否点击到当前LED，在end中通过type来判断是否闪烁，
                              //这里默认变化颜色到黑色是为闪烁效果
                              begin: flagList[i] ? currentColor : colorList[i],
                              end: typeList[i]
                                  ? Colors.black
                                  : (flagList[i] ? currentColor : colorList[i]))
                          .animate(_controller));
                    }
                    //showWidget是显示的widget组件列表
                    List<Widget> showWidget = [];
                    for (var i = 0; i < showData.length; i++) {
                      //print(showData[i]["top"]);
                      //当点击的时候，该索引下的flag为true，并且该LED的颜色控制为当前选择的值
                      //并且还要考虑是否需要闪烁效果
                      //这里利用stack和positioned组件来实现绝对定位，通过传入的top和left值来定位
                      //print(showData[i]["top"] * _treeHeight);
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
                        top: showData[i]["top"] * _treeHeight,
                        left: showData[i]["left"] * _treeWidth,
                      ));
                    }
                    return GestureDetector(
                      child: Container(
                        child: Stack(
                          children: showWidget,
                        ),
                        width: _treeWidth,
                        height: _treeHeight,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(17),
                            border:
                                Border.all(color: Colors.blueAccent, width: 1)),
                      ),
                    );
                  }),
              SizedBox(
                height: 20,
              ),
              ColorPicker(
                //颜色选择器，将showLabel置为false则不显示选择的框
                pickerColor: pickerColor,
                onColorChanged: changeColor,
                showLabel: false,
                pickerAreaHeightPercent: 0.2,
              ),
              Container(
                  child: Row(
                children: <Widget>[
                  Container(
                    //这是控制是否闪烁的按钮，当按下该按钮时，type为反就可以了
                    child: FloatingActionButton(
                      onPressed: () => type = !type,
                      child: Text("闪烁"),
                      heroTag: "spark",
                    ),
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.only(left: 220),
                  ),
                  Container(
                    child: FloatingActionButton(
                      onPressed: () {
                        String tmpStr = getRandom();
                        print(tmpStr);
                        _save(tmpStr);
                      },
                      child: Text("保存"),
                      heroTag: "save",
                    ),
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.only(left: 20),
                  ),
                ],
              )),
            ],
          ),
        ));
  }
}
