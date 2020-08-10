import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class clas1 {
  int i = 0;
}
class customPacket {//Ver.Alpha 0.1
//  实例化后请不要直接执行子函数，初始化未完成的情况下大部分子函数都会出错
//  调试的时候请像下面这样调用，定时执行来等待初始化完成
//  const timeout = const Duration(seconds: 3);//延迟3秒
//  Timer(timeout, () {
//    //在这里调用
//  });

  int LEDamount = 0;
  Uint8List message;
  Uint8List streamMessage;
  int streamNo = 0;
  int dataLength = 0;
  bool error = false;
  int openedFile = 0;
  bool streamControl = true;//true为关闭，false为开启
  int totalMemory = 0;
  int usedMemory = 0;

  customPacket() {
    getAmount();//获取灯的数量
    getMemoryInfo();//获取空间信息
    print("created.");
  }

  Future<void> test() async {//用来测试崩wifi的测试函数
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    Socket socket = await Socket.connect(LEDaddr, 6600); //TCP
    Uint8List fileMessage = Uint8List(12);//发送的数据包
    Uint8List receiveData;
    var sendData = ByteData.view(fileMessage.buffer);
    int num = 0x53485955;
    sendData.setUint32(0, num);//头部4字节
    sendData.setUint8(4, 0x04);//长度低8位
    sendData.setUint8(5, 0x00);//长度高8位
    sendData.setUint8(8, 0x01);//长度低8位
    sendData.setUint8(9, 0x01);//编号
    sendData.setUint8(10, 0x08);
    sendData.setUint8(11, 0x02);//写打开

    int check = 0;//校验
    for (int i = 8; i < 12; i++) {
      check += sendData.getUint8(i);
    }
    check = check & 0xff;//低8位
    int check2 = 0xff - check;//校验高8位
    sendData.setUint8(6, check);
    sendData.setUint8(7, check2);
    try{
      socket.add(fileMessage);//发送数据包
      socket.listen((datarec) {//接受数据包
        receiveData =  datarec;
        print(receiveData);
        print("open file success.");
        socket.close();
      }); //TCPEND
    }catch(e){
      print("Link error. Please check network");
      error = true;
      socket.close();
    }
  }
  void writeFile(int dataNo,Uint8List data) async {//dataNo文件序号1-10
    //重大bug稳定复现，暂时不可用
    if((data.length%LEDamount == 0) && dataNo > 0 && dataNo < 11){
      int packAmount = data.length~/LEDamount;
      int now = 0;
      int next = 0;
      const streamTime = const Duration(milliseconds: 1000);//0.2s一次
      InternetAddress LEDaddr = InternetAddress("192.168.4.1");
      Uint8List fileMessage;
      Uint8List receiveData;
      Socket socket = await Socket.connect(LEDaddr, 6600); //TCP
      Timer.periodic(streamTime, (timer){ //callback function
        if(now<=packAmount&&now==next){//有新包则发送
          print("now is" + now.toString());
          next++;
          if(now == 0){
            fileMessage = Uint8List(12);//发送的数据包
            var sendData = ByteData.view(fileMessage.buffer);
            int num = 0x53485955;
            sendData.setUint32(0, num);//头部4字节
            sendData.setUint8(4, 0x04);//长度低8位
            sendData.setUint8(5, 0x00);//长度高8位
            sendData.setUint8(8, 0x01);//长度低8位
            sendData.setUint8(9, 0x00);//编号
            sendData.setUint8(10, dataNo+2);
            sendData.setUint8(11, 0x01);//写打开

            int check = 0;//校验
            for (int i = 8; i < 12; i++) {
              check += sendData.getUint8(i);
            }
            check = check & 0xff;//低8位
            int check2 = 0xff - check;//校验高8位
            sendData.setUint8(6, check);
            sendData.setUint8(7, check2);
            try{
              socket.add(fileMessage);//发送数据包
              socket.listen((datarec) {//接受数据包
                receiveData =  datarec;
                print(receiveData);
                if(receiveData[8]==0x81&&receiveData[9]==0x00&&receiveData[11]==0x00){
                  now++;
                  print("open file success.");
                }
                else{
                  print("Return data error. Please check network");
                  now = packAmount+1;
                }
              }); //TCPEND
            }catch(e){
              print("Link error. Please check network");
              now = packAmount+1;
              error = true;
            }
          }else{
            fileMessage = Uint8List(14+LEDamount*3);//发送的数据包
            var sendData = ByteData.view(fileMessage.buffer);
            int num = 0x53485955;
            sendData.setUint32(0, num);//头部4字节
            sendData.setUint8(4, ((LEDamount*3+6 >> 0) & 0xff));//长度低8位
            sendData.setUint8(5, ((LEDamount*3+6 >> 8) & 0xff));//长度高8位
            sendData.setUint8(8, 0x04);//命令
            sendData.setUint8(9, 0x02);//参数
            sendData.setUint8(10, ((LEDamount*3 >> 0) & 0xff));//长度低8位
            sendData.setUint8(11, ((LEDamount*3 >> 8) & 0xff));//长度高8位
            sendData.setUint8(12, 0x00);//时间低8位
            sendData.setUint8(13, 0x00);//时间高8位
            for (int i = 0; i < LEDamount; i++) {//填充数据
              sendData.setUint8(i+14, data[i+(now-1)*LEDamount]);
            }
            int check = 0;//校验
            for (int i = 8; i < 14 + LEDamount; i++) {
              check += sendData.getUint8(i);
            }
            check = check & 0xff;//低8位
            int check2 = 0xff - check;//校验高8位
            sendData.setUint8(6, check);
            sendData.setUint8(7, check2);
            try{
              socket.add(fileMessage);//发送数据包
              socket.listen((datarec) {//接受数据包
                now++;
                receiveData =  datarec;
                if(receiveData[8]==0x84&&receiveData[9]==0x00){
                  now++;
                  print("write file success.");
                }
                else{
                  print("Return data error. Please check network");
                  now = packAmount+1;
                }
              }); //TCPEND
            }catch(e){
              print("Link error. Please check network");
              now = packAmount+1;
              error = true;
            }
          }
        }else{//now>amount
          fileMessage = Uint8List(12);//发送的数据包
          var sendData = ByteData.view(fileMessage.buffer);
          int num = 0x53485955;
          sendData.setUint32(0, num);//头部4字节
          sendData.setUint8(4, 0x04);//长度低8位
          sendData.setUint8(5, 0x00);//长度高8位
          sendData.setUint8(8, 0x01);//长度低8位
          sendData.setUint8(9, 0x01);//编号
          sendData.setUint8(10, dataNo+2);
          sendData.setUint8(11, 0x02);//关闭文件

          int check = 0;//校验
          for (int i = 8; i < 12; i++) {
            check += sendData.getUint8(i);
          }
          check = check & 0xff;//低8位
          int check2 = 0xff - check;//校验高8位
          sendData.setUint8(6, check);
          sendData.setUint8(7, check2);
          try{
            socket.add(fileMessage);//发送数据包
            socket.listen((datarec) {//接受数据包
              receiveData =  datarec;
              if(receiveData[8]==0x81&&receiveData[9]==0x01&&receiveData[11]==0x00){
                now++;
                socket.close();
                print("open file success.");
              }
              else{
                print("Return data error. Please check network");
                now = packAmount+1;
              }
            }); //TCPEND
          }catch(e){
            print("Link error. Please check network");
            now = packAmount+1;
            error = true;
          }
        }
        if(streamControl) timer.cancel();
      });
    }
    else{
      print("Input data length error.");
    }
  }

  void getMemoryInfo() async {

    Uint8List message2 = Uint8List(9);//发送的数据包
    print(message2.length);
    var data2 = ByteData.view(message2.buffer);
    int num2 = 0x53485955;
    data2.setUint32(0, num2);//头部4字节
    data2.setUint8(4, ((1 >> 0) & 0xff));//长度低8位
    data2.setUint8(5, ((1 >> 8) & 0xff));//长度高8位
    data2.setUint8(8, 0x05);//
    int check = 0;//校验
    for (int i = 8; i < 9; i++) {
      check += data2.getUint8(i);
    }
    check = check & 0xff;//低8位
    int check2 = 0xff - check;//校验高8位
    data2.setUint8(6, check);
    data2.setUint8(7, check2);

    Uint8List receiveData;
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    try{
      Socket socket = await Socket.connect(LEDaddr, 6600); //TCP
      socket.add(message2);//发送数据包
      socket.listen((datarec) {//接受数据包
        receiveData =  datarec;
        var data = ByteData.view(receiveData.buffer);
        if(receiveData[8]==0x85){
          this.totalMemory = data.getUint8(12);
          for(int i=11;i>8;i--){
            this.totalMemory = this.totalMemory << 8;
            this.totalMemory = this.totalMemory | data.getUint8(i);
          }
          this.usedMemory = data.getUint8(16);
          for(int i=15;i>12;i--){
            this.usedMemory = this.usedMemory << 8;
            this.usedMemory = this.usedMemory | data.getUint8(i);
          }
          print("total Memory:"+totalMemory.toString());
          print("used Memory:"+usedMemory.toString());
        }
        else{
        }
      }); //TCPEND
      socket.close();
    }catch(e){
      print("Link error. Please check network");
      error = true;
    }
  }

  void setStreamMessage(int no,Uint8List data){//设置流控信息,no!=0,传入数据最快155ms一次，请在外部设置好
    streamNo = no;
    streamMessage = data;
  }

  void endUDPStream(){//结束UDP流控
    streamControl = true;
    streamNo = 0;
    print("Stream end.");
  }

  void startUDPStream(){//开始UDP流控
    streamControl = false;
    int sendNo = 0xff;//发送序号
    const streamTime = const Duration(milliseconds: 75);//0.075s一次
    Uint8List sendStreamMessage;
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    Uint8List finalStreamMessage;
    Timer.periodic(streamTime, (timer) { //callback function
      if((sendNo != (streamNo & 0xff)) && (streamNo != 0)){//有新包则发送
        sendNo = (streamNo & 0xff);
        sendStreamMessage = streamMessage;
        finalStreamMessage = Uint8List(12+LEDamount*3);//发送的数据包
        var data = ByteData.view(finalStreamMessage.buffer);
        int num = 0x53485955;
        data.setUint32(0, num);//头部4字节
        data.setUint8(4, ((LEDamount*3+4 >> 0) & 0xff));//长度低8位
        data.setUint8(5, ((LEDamount*3+4 >> 8) & 0xff));//长度高8位
        data.setUint8(8, 0x02);//长度低8位
        data.setUint8(9, sendNo);//编号
        data.setUint8(10, 0x01);//持续0.2s
        data.setUint8(11, 0x00);
        for(int i=0;i<LEDamount*3;i++){//填充数据
          finalStreamMessage[i+12] = sendStreamMessage[i];
        }
        int check = 0;//校验
        for (int i = 8; i < 12 + LEDamount*3; i++) {
          check += data.getUint8(i);
        }
        check = check & 0xff;//低8位
        int check2 = 0xff - check;//校验高8位
        data.setUint8(6, check);
        data.setUint8(7, check2);



        var udpSocket = RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        udpSocket.then((socket) {
          socket.send(finalStreamMessage, LEDaddr, 6000); //发送数据
          socket.listen((event) {
            if (event == RawSocketEvent.read) {//接收数据
              var recData = socket
                  .receive()
                  .data;
              print(recData[10]);
              if(recData[10] > 20) print("over!");
            }
          });
        });
      }
      if(streamControl) timer.cancel();
    });
  }

  void turnLightToUDP(){//开启udp模式，任何需要udp的功能都要先执行这个
    Uint8List sendData = Uint8List(4);
    var data = ByteData.view(sendData.buffer);
    data.setUint8(0, 0x00);
    data.setUint8(1, 0x01);
    data.setUint8(2, 0x01);
    data.setUint8(3, 0x01);
    setData(4, sendData);
    sendTCP();
    print("Turn to udp.");
  }

  void openFile(int num){//未测试
    //打开存储的灯光配置文件1-10
    if(num>0 && num<11){
      openedFile = num;
      Uint8List sendData = Uint8List(4);
      var data = ByteData.view(sendData.buffer);
      data.setUint8(0, 0x01);
      data.setUint8(1, 0x01);
      data.setUint8(2, num+2);
      data.setUint8(3, 0x00);
      setData(4, sendData);
      print("File start.");
      sendTCP();
    }else{
      print("number error.");
    }
  }

  void closeFile(){//关闭当前打开的文件，未测试，大概率重大bug
    if(openedFile!=0){
      Uint8List sendData = Uint8List(4);
      var data = ByteData.view(sendData.buffer);
      data.setUint8(0, 0x01);
      data.setUint8(1, 0x01);
      data.setUint8(2, openedFile+2);
      data.setUint8(3, 0x02);
      setData(4, sendData);
      print("File end.");
      openedFile = 0;
      sendTCP();
    }else{
      print("No File Opening.");
    }
  }

  void testLED(){//执行显示测试，结束后关灯//getAmount();//先执行获取灯的数量主要是因为初始化时有概率初始化失败
    print("led amount is: "+LEDamount.toString());

    turnLightToUDP();
    const timeout2 = const Duration(seconds: 2);//2s一次
    int count = 0;
    var rand = Random();
    Uint8List sendData2 = Uint8List(LEDamount*3+5);
    var data2 = ByteData.view(sendData2.buffer);
    data2.setUint8(0, 0x01);
    data2.setUint8(1, 0x00);//从哪开始
    data2.setUint8(2, 0x00);
    data2.setUint8(3, (LEDamount >> 0) & 0xff);//持续多长
    data2.setUint8(4, (LEDamount >> 8) & 0xff);
    if(LEDamount>0){//只有在获取到灯的数量之后才执行测试
      Timer.periodic(timeout2, (timer) { //callback function
        print(count);
        count++;
        //每隔1s
        switch (count){
          case 1:{
            for(int i=5;i<LEDamount*3+5;){
              data2.setUint8(i, 0x11);//R
              data2.setUint8(i+1, 0x00);
              data2.setUint8(i+2, 0x00);
              i = i + 3;
            }
          }break;
          case 2:{
            for(int i=5;i<LEDamount*3+5;){
              data2.setUint8(i, 0x00);//G
              data2.setUint8(i+1, 0x11);
              data2.setUint8(i+2, 0x00);
              i = i + 3;
            }
          }break;
          case 3:{
            for(int i=5;i<LEDamount*3+5;){
              data2.setUint8(i, 0x00);//B
              data2.setUint8(i+1, 0x00);
              data2.setUint8(i+2, 0x11);
              i = i + 3;
            }
          }break;
          case 4:{
            for(int i=5;i<LEDamount*3+5;i++){//random
              data2.setUint8(i, rand.nextInt(128) & 0xff);
            }
          }break;
          case 5:{
            for(int i=5;i<LEDamount*3+5;i++){//random2
              data2.setUint8(i, rand.nextInt(64) & 0xff);
            }
          }break;
          case 6:{
            for(int i=5;i<LEDamount*3+5;i++){//close
              data2.setUint8(i, 0x00);
            }
          }break;
        }
        setData(LEDamount*3+5, sendData2);
        sendUDP();
        if(count > 6)
          timer.cancel();  // 取消定时器
      });
    }//endif
  }//end function

  void sendTCP() async {
    //Uint8List returnMessage;
    try{
      InternetAddress LEDaddr = InternetAddress("192.168.4.1");
      Socket socket = await Socket.connect(LEDaddr, 6600); //TCP
      socket.add(message);//发送数据包

      socket.listen((datarec) {
        //print("TCP return :" + datarec.toString());
      }); //TCPEND
      await socket.flush();
      await socket.close();
    }catch(e){
      print("Link end.");
    }
  }
  void sendUDP(){
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    var udpSocket = RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    udpSocket.then((socket) {
      socket.send(message, LEDaddr, 6000);//发送数据
      socket.listen((event) {
        if (event == RawSocketEvent.read) {
          var recData = socket
              .receive()
              .data;
          //print(recData);
        }
      });
    //print("sendUDP");
    }); //UDPEND
  }

  bool setData(int length,Uint8List dataIn){
    //输入长度，Uint8List类型的数组，自动拼装头部和校验部分到message
    dataLength = length;//每个数据包数据部分长度
    if(length > 1392) return false;//最大长度不超过1392
    message = Uint8List(8+length);//发送的数据包包头
    var data = ByteData.view(message.buffer);
    int num = 0x53485955;
    data.setUint32(0, num);//头部4字节
    data.setUint8(4, ((dataLength >> 0) & 0xff));//长度低8位
    data.setUint8(5, ((dataLength >> 8) & 0xff));//长度高8位
    for(int i=0;i<length;i++){//填充数据
      message[i+8] = dataIn[i];
    }
    int check = 0;//校验
    for (int i = 8; i < 8 + dataLength; i++) {
      check += data.getUint8(i);
    }
    check = check & 0xff;//低8位
    int check2 = 0xff - check;//校验高8位
    data.setUint8(6, check);
    data.setUint8(7, check2);
    //print("message is"+message.toString());

    return true;
  }

  void getAmount() async {//获取灯的数量，不需要手动调用，实例化时自动调用一次
    Uint8List message2 = Uint8List(9);//发送的数据包
    var data2 = ByteData.view(message2.buffer);
    int num2 = 0x53485955;
    data2.setUint32(0, num2);//头部4字节
    data2.setUint8(4, ((1 >> 0) & 0xff));//长度低8位
    data2.setUint8(5, ((1 >> 8) & 0xff));//长度高8位
    data2.setUint8(8, 0x00);//

    int check = 0;//校验
    for (int i = 8; i < 9; i++) {
      check += data2.getUint8(i);
    }
    check = check & 0xff;//低8位
    int check2 = 0xff - check;//校验高8位
    data2.setUint8(6, check);
    data2.setUint8(7, check2);

    Uint8List receiveData;
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    try{
      Socket socket = await Socket.connect(LEDaddr, 6600); //TCP
      socket.add(message2);//发送数据包
      socket.listen((datarec) {//接受数据包
        //print("!!!");
        receiveData =  datarec;
        var data = ByteData.view(receiveData.buffer);
        if(receiveData[8]==128){
          print(receiveData);
          this.LEDamount = data.getUint8(11);
          this.LEDamount = this.LEDamount << 8;
          this.LEDamount = this.LEDamount | data.getUint8(10);
          print("get amount:"+LEDamount.toString());
        }
        else{
          LEDamount = 25565;
        }
      }); //TCPEND
      socket.close();
    }catch(e){
      print("Link error");
      error = true;
    }
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  _incrementCounter() async {
    var cust = customPacket();

    Uint8List sendData = Uint8List(4800);
      var data = ByteData.view(sendData.buffer);
      var rand = Random();
      for(int i=0;i<4800;i++){//random2
        data.setUint8(i, rand.nextInt(64) & 0xff);
      }

      const timeout = const Duration(seconds: 3);
      Timer(timeout, () {
        print("Timer start");
        //cust.writeFile(3, sendData);
        cust.test();
      });



//    cust.turnLightToUDP();
//
//    const timeout = const Duration(seconds: 3);
//    Timer(timeout, () {
//      cust.startUDPStream();
//      Uint8List sendData = Uint8List(1200);
//      var data = ByteData.view(sendData.buffer);
//      var rand = Random();
//      const timeo = const Duration(milliseconds: 150);//0.2s一次
//      int count = 1;
//      Timer.periodic(timeo, (timer) { //callback function
//        for(int i=0;i<1200;i++){//random2
//          data.setUint8(i, rand.nextInt(64) & 0xff);
//        }
//        cust.setStreamMessage(count, sendData);
//        count++;
//        if(count>100){
//          cust.endUDPStream();
//          timer.cancel();
//        }
//      });
//    });

//      const timeo = const Duration(milliseconds: 5000);//5s一次
//      int count = 1;
//      Timer.periodic(timeo, (timer) { //callback function
//        if(count==1){
//          cust.openFile(1);
//        }
//        if(count==2){
//          cust.closeFile();
//        }
//        count++;
//        if(count>2){
//          timer.cancel();
//        }
//      });





//    Uint8List sendData = Uint8List(14);
//    var data = ByteData.view(sendData.buffer);
//    data.setUint8(0, 0x01);
//    data.setUint8(1, 0xff);
//    data.setUint8(2, 0x00);
//    data.setUint8(3, 0x03);
//    data.setUint8(4, 0x00);
//
//    data.setUint8(5, 0x22);
//    data.setUint8(6, 0x00);
//    data.setUint8(7, 0x00);
//
//    data.setUint8(8, 0x00);
//    data.setUint8(9, 0x22);
//    data.setUint8(10, 0x00);
//
//    data.setUint8(11, 0x00);
//    data.setUint8(12, 0x00);
//    data.setUint8(13, 0x22);
//    cust.setData(14, sendData);
//    cust.sendUDP();


    print("Finish.");

//  const timeout = const Duration(seconds: 1);
//  Timer(timeout, () {
//    //到时回调
//    //cust.openFile(2);
//    cust.testLED();
//  });
  //随机颜色







  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
