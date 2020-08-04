import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../tools/Circle.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../res/treeRes.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

class editPage extends StatefulWidget {
  List getJson;
  String fileName;

  //editPage({Key key, @required this.getJson}) : super(key: key);
  editPage(List gjson, String name) {
    this.getJson = gjson;
    this.fileName = name;
  }

  @override
  _editPageState createState() => _editPageState(this.getJson, this.fileName);
}

class _editPageState extends State<editPage>
    with SingleTickerProviderStateMixin {
  List getJSON;
  String fileName;

  _editPageState(List gjson, String name) {
    this.getJSON = gjson;
    this.fileName = name;
  }

  //type为判断是否按下闪烁按钮
  bool type = false;
  //typeList为所有LED灯闪烁标志
  List<bool> typeList = [];
  //colorList为所有LED灯的颜色控制，一个LED灯对应一个
  List<Color> colorList = [];
  //将要写入文件的值
  List res = [];

  //flagList为是否点击标志
  List<bool> flagList = [];
  //turnColList为颜色控制器
  List turnColList = [];

  //该函数为初始化typeList和colorList的数量，默认初始化为false和黑色
  void getTypeAndColor(List list) {
    for (var i = 0; i < list.length; i++) {
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

  var textController = TextEditingController();

  Color getColor(String str) {
    String objStr = str.substring(str.indexOf("(") + 1, str.indexOf(")"));
    return Color(int.parse(objStr));
  }

  void _showDialog(String str) {
    slideDialog.showSlideDialog(
      context: context,
      child: Column(
        children: <Widget>[
          Text("修改名称"),
          SizedBox(
            height: 20,
          ),
          TextField(
            decoration: InputDecoration(
                hintText: textController.text, border: OutlineInputBorder()),
            controller: textController,
          ),
          SizedBox(height: 20),
          Container(
            child: FloatingActionButton(
              child: Text("确定"),
              onPressed: () {
                print(textController.text);
                _save(str);
                Navigator.of(context).pop(1);
              },
            ),
            margin: EdgeInsets.only(left: 280),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(milliseconds: 100), vsync: this);
    _controller.repeat(reverse: true);

    //getTypeAndColor(getJSON);

    for (var i = 0; i < getJSON.length; i++) {
      typeList.add(getJSON[i]["type"] == 1 ? false : true);
      colorList.add(getColor(getJSON[i]["begincolor"]));
    }

    for (var i = 0; i < getJSON.length; i++) {
      flagList.add(false);
      turnColList.add(ColorTween(
              begin: flagList[i] ? currentColor : colorList[i],
              end: typeList[i]
                  ? Colors.black
                  : (flagList[i] ? currentColor : colorList[i]))
          .animate(_controller));
    }

    textController.text = getJSON[0]["name"];

    setState(() {});

    //初始化外部参数
    //getTypeAndColor(showData);
    super.initState();
  }

  void refresh() {
    for (var i = 0; i < getJSON.length; i++) {
      turnColList[i] = (ColorTween(
              begin: flagList[i] ? currentColor : colorList[i],
              end: typeList[i]
                  ? Colors.black
                  : (flagList[i] ? currentColor : colorList[i]))
          .animate(_controller));
      flagList[i] = false;
    }
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
        "name": textController.text
      });
    }
    String result = json.encode(res);
    File file = await _getLocalFile(str);
    file.writeAsString(result);

    setState(() {
      res = [];
    });
    //print(result is String);
  }

  void _delete(String name) async {
    File tmp = await _getLocalFile(name);
    tmp.deleteSync(recursive: false);
    setState(() {
      print("删除成功！！！！！");
    });

    File file = await _getLocalFile("nameData");
    String str = await file.readAsString();
    String res = str.substring(0, str.indexOf(name)) +
        str.substring(str.indexOf(name) + 11);
    file.writeAsString(res);
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
          title: Text("edit LED"),
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
                    List<Widget> getWidget = [];
                    for (var i = 0; i < this.getJSON.length; i++) {
                      // print("this is $i");
                      // print(getJSON[i]["dy"] * _treeHeight);
                      getWidget.add(
                        Positioned(
                          child: Container(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  flagList[i] = true;
                                  typeList[i] = type;
                                  colorList[i] = currentColor;
                                  refresh();
                                });
                              },
                              onTapDown: (event) => print(event.localPosition),
                              child: CustomPaint(
                                  painter: CirclePainter(
                                      0.0, 0.0, turnColList[i].value),
                                  size: Size(16, 16)),
                            ),
                          ),
                          top: getJSON[i]["dy"] * _treeHeight,
                          left: getJSON[i]["dx"] * _treeWidth,
                        ),
                      );
                    }

                    getWidget.add(Column(
                      children: <Widget>[
                        SizedBox(
                          height: 400,
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              child: Icon(Icons.edit,size: 18,),
                              margin: EdgeInsets.only(left: 130),
                              
                            ),
                            Container(
                              child: GestureDetector(
                                child: Text(getJSON[0]["name"],
                                            style: TextStyle(fontSize: 18),),
                                onTap: () => _showDialog(this.fileName),
                              ),                           
                              margin: EdgeInsets.only(left: 5),
                            )
                          ],
                        )                       
                      ],
                    ));

                    return GestureDetector(
                      child: Container(
                        child: Stack(
                          children: getWidget,
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
                    margin: EdgeInsets.only(left: 20),
                  ),
                  Container(
                    child: FloatingActionButton(
                      onPressed: () {
                        print(this.fileName);
                        _save(this.fileName);
                      },
                      child: Text("保存"),
                      heroTag: "save",
                    ),
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.only(left: 20),
                  ),
                  Container(
                    child: FloatingActionButton(
                      onPressed: () {},
                      child: Text("应用"),
                      heroTag: "apply",
                    ),
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.only(left: 100),
                  ),
                  Container(
                    child: FloatingActionButton(
                      onPressed: () {
                        _delete(this.fileName);
                      },
                      child: Text("删除"),
                      heroTag: "delete",
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
