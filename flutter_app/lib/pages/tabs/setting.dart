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
  Color currentColor = Colors.limeAccent;
  Color pickerColor = Color(0xff443a49);

  void changeColor(Color color) => setState(() {
        pickerColor = color;
        currentColor = pickerColor;
      });
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(duration: Duration(seconds: 1), vsync: this);
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
                var turnCol = ColorTween(begin: currentColor, end: currentColor)
                    .animate(_controller);
                //print(turnCol.value);
                // return CircleAnimated(
                //     10.0, 30.0, turnCol.value, turnCol.value, 100);
                return CustomPaint(
                  painter: LinePainter(10.0, 30.0, turnCol.value),
                );
              }),
          SizedBox(
            height: 420,
          ),
          ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            showLabel: true,
            pickerAreaHeightPercent: 0.2,
          ),
        ],
      ),
    );
  }
}
