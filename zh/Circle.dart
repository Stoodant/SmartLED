import 'package:flutter/material.dart';

class CircleAnimated extends StatefulWidget {//画圆
  Color _start;
  Color _end;
  int _t;

  CircleAnimated(Color startColor,Color endColor,int time){//Color开始颜色 Color结束颜色 int时间
    _start = startColor;
    _end = endColor;
    _t = time;
  }
  @override
  _CircleAnimatedState createState() => _CircleAnimatedState(_start,_end,_t);
}

class _CircleAnimatedState extends State<CircleAnimated> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Color _startColor = Colors.amber;
  Color _endColor = Colors.teal;
  int _time = 3;

  _CircleAnimatedState(Color start, Color end, int t){
    _startColor = start;
    _endColor = end;
    _time = t;
  }

  @override
  void initState() {
    _controller = AnimationController(
        duration:Duration(seconds: _time),
        vsync: this);
    _controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child){
              var turnCol = ColorTween(begin: _startColor ,end: _endColor).animate(_controller);
              return Container(
                child: CustomPaint(
                  painter: LinePainter(turnCol.value),
                ),
              );
            }
        ),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),///圆角
          border: Border.all(color: Colors.blueAccent,width: 1)///边框颜色、宽
      ),
      width: 200,
      height: 300,
    );
  }
}

class LinePainter extends CustomPainter {
  Color _col = Colors.black;
  //定义画笔
  Paint _paint = new Paint()
    ..color = Colors.blue
    ..strokeCap = StrokeCap.square
    ..isAntiAlias = true
    ..strokeWidth = 3.0
    ..style = PaintingStyle.fill;
  LinePainter(Color col){
    _col = col;
  }
  @override
  void paint(Canvas canvas, Size size) {
    //绘制圆 参数为中心点，半径，画笔
    canvas.drawCircle(Offset(0.0, 0.0), 15.0, _paint
      ..color = _col);
  }
  ///重写是否需要重绘的
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
