import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:ui';

void main() {
  int dataLength = 1;
  int jiaoyan = 0;

  int controlData = 0x00;
  var data = ByteData(12);
  int num = 0x55594853;
  data.setInt32(0, num);
  data.setInt16(4, dataLength);
  data.setInt16(8, controlData);
  for (int i = 8; i < 8 + dataLength; i++) {
    jiaoyan += data.getInt8(i);
  }
  int jiaoyan2 = 0xff - (jiaoyan & 255);
  data.setInt8(6, jiaoyan2);
  data.setInt8(7, jiaoyan);
  print(jiaoyan2);

  List<int> sendData = List<int>(); //正式发送的数据
  for (int i = 0; i < 8 + dataLength; i += 4) {
    sendData.add(data.getInt32(i));
  }
  print(sendData);

  InternetAddress LEDaddr = InternetAddress("192.168.4.1");
  ServerSocket.bind(LEDaddr, 6600) //绑定端口4041，根据需要自行修改，建议用动态，防止端口占用
      .then((serverSocket) {
    serverSocket.listen((socket) {
      socket.listen((s) {
        print(s);
      });
    });
  });
  Socket.connect('192.168.4.1', 6600).then((socket) async {
    //socket.transform(utf8.decoder).listen(print);
    socket.add(sendData);
  });
}
