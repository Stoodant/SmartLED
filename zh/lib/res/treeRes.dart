import 'package:flutter/material.dart';


List listData = [
  //原点为左上角，dx(double)向右，dy(double)向下，传入0.0-1.0的相对百分比坐标
  //如x坐标为方框内从左到右74%的地方则传入dx = 0.74
  {
    "dx": 0.0,
    "dy": 0.0,
    "begincolor": Colors.blue,
    "endcolor": Colors.white,
    "time": 100
  },
  {
    "dx": 0.5,
    "dy": 0.5,
    "begincolor": Colors.white,
    "endcolor": Colors.blue,
    "time": 100
  },
  {
    "dx": 0.74,
    "dy": 0.95,
    "begincolor": Colors.white,
    "endcolor": Colors.blue,
    "time": 100
  },
];


