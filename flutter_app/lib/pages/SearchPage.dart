import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key key}) : super(key: key);

  void _incrementCounter() {
    int dataLength = 1;
    int jiaoyan = 0;

    int controlData = 0x00;
    var data = ByteData(12);
    int num = 0x55594853;
    data.setInt32(0, num);
    data.setInt16(4, dataLength);
    data.setInt16(8, controlData);
    for(int i=8;i<8+dataLength;i++){
      jiaoyan += data.getInt8(i);
    }
    int jiaoyan2 = 0xff - (jiaoyan & 255);
    data.setInt8(6, jiaoyan2);
    data.setInt8(7, jiaoyan);
    print(jiaoyan2);

    List<int> sendData = List<int>();//正式发送的数据
    for(int i=0;i<8+dataLength;i+=4){
      sendData.add(data.getInt32(i));
    }
    print(sendData);

    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    ServerSocket
        .bind(InternetAddress.loopbackIPv4,4565) //绑定端口4041，根据需要自行修改，建议用动态，防止端口占用
        .then((serverSocket) {
      serverSocket.listen((socket) {
        socket.listen((s) {
          print(s);
        });
      }
      );
        });

      Socket.connect('192.168.4.1', 6000).then((socket) async{
      //socket.transform(utf8.decoder).listen(print);
      socket.add(sendData);


    });

//    Socket socket = Socket.connect(InternetAddress.LOOPBACK_IP_V4, 6000) as Socket;
//
//    print("发送消息");
//    socket.add(sendData);
//    socket.close().then((response){
//      response.cast<List<int>>().transform(utf8.decoder).listen((content) {
//        print(content);
//      });
//    });
//    var rawDgramSocket = RawDatagramSocket.bind(InternetAddress.anyIPv4, 6000);
//
//    rawDgramSocket.then((socket) {
      //socket.broadcastEnabled = true;


//      socket.listen((e) {
//        Datagram dg = socket.receive();
//        if (dg != null) {
//          print("ans : " + dg.data[0].toString());
//        }
//      });
//      rawDgramSocket.then((socket) {
//        int result = socket.send(sendData, LEDaddr, 6000);
//        print("已发送: " + result.toString());
//
//        socket.listen((event) {
//          if(event == RawSocketEvent.read) {
//            print(utf8.decode(socket.receive().data));
//          }
//        });
//      });

      //

//    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("search Page"),
        ),
        body: Container(
          child: FloatingActionButton(
            onPressed: ()=> _incrementCounter()
          ),
          width: 100,
          height: 100,
        )
      );
  }
}
