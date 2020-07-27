import 'package:flutter/material.dart';

List listData = [
  //原点为左上角，dx(double)向右，dy(double)向下，传入0.0-1.0的相对百分比坐标
  //如x坐标为方框内从左到右74%的地方则传入dx = 0.74
  //pwm：单色闪烁占空比，是在time毫秒内前pwm*time毫秒内亮beginColor，endColor无效
  {
    "dx": 0.5,
    "dy": 0.1,
    "begincolor": Colors.blue,
    "endcolor": Colors.yellow,
    "time": 1000,
    "type": 1,
    "pwm": 1.0
  },
  {
    "dx": 0.45,
    "dy": 0.2,
    "begincolor": Colors.yellow,
    "endcolor": Colors.greenAccent,
    "time": 1000,
    "type": 1,
    "pwm": 1.0
  },
  {
    "dx": 0.55,
    "dy": 0.2,
    "begincolor": Colors.greenAccent,
    "endcolor": Colors.white24,
    "time": 1000,
    "type": 1,
    "pwm": 1.0
  },
  {
    "dx": 0.40,
    "dy": 0.3,
    "begincolor": Colors.white24,
    "endcolor": Colors.pinkAccent,
    "time": 1000,
    "type": 1,
    "pwm": 1.0
  },
  {
    "dx": 0.50,
    "dy": 0.3,
    "begincolor": Colors.pinkAccent,
    "endcolor": Colors.blue,
    "time": 1000,
    "type": 1,
    "pwm": 1.0
  },
  {
    "dx": 0.60,
    "dy": 0.3,
    "begincolor": Colors.lightGreenAccent,
    "endcolor": Colors.blue,
    "time": 500,
    "type": 2,
    "pwm": 0.2
  },
];

List showData = [
  {
    "top":100.0,
    "left":100.0
  },
  {
    "top":80.0,
    "left":120.0
  },
  {
    "top":80.0,
    "left":160.0
  },
  {
    "top":120.0,
    "left":120.0
  },
  {
    "top":120.0,
    "left":160.0
  },
];
