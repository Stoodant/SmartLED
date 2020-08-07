class customPacket {//ver0.4
  int LEDamount = 0;
  Uint8List message;
  Uint8List streamMessage;
  int dataLength = 0;
  bool error = false;
  int opendFile = 0;
  bool streamControl = true;//true为关闭，false为开启

  customPacket() {

    getAmount();//获取灯的数量
    print("created.");
  }
  void startUDPStream(){//开启UDP流控
    var rand = Random();
    const streamTime = const Duration(milliseconds: 190);//0.19s一次
    Uint8List sendStreamMessage;
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    int count = 0;
    Timer.periodic(streamTime, (timer) { //callback function
      sendStreamMessage = streamMessage;
      finalStreamMessage = Uint8List(8+LEDamount*3);//发送的数据包包头
      var data = ByteData.view(message.buffer);
      int num = 0x53485955;
      data.setUint32(0, num);//头部4字节
      data.setUint8(4, ((LEDamount*3+4 >> 0) & 0xff));//长度低8位
      data.setUint8(5, ((LEDamount*3+4 >> 8) & 0xff));//长度高8位
      data.setUint8(8, 0x02);//长度低8位
      data.setUint8(9, (count & 0xff));//编号
      data.setUint8(10, 0x01);//持续0.2s
      data.setUint8(11, 0x00);
      for(int i=0;i<LEDamount*3;i++){//填充数据
        message[i+12] = sendStreamMessage[i];
      }
      int check = 0;//校验
      for (int i = 8; i < 8 + LEDamount*3; i++) {
        check += data.getUint8(i);
      }
      check = check & 0xff;//低8位
      int check2 = 0xff - check;//校验高8位
      data.setUint8(6, check);
      data.setUint8(7, check2);
      
      
      
      var udpSocket = RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      udpSocket.then((socket) {
        socket.send(message, LEDaddr, 6000); //发送数据
        socket.listen((event) {
          if (event == RawSocketEvent.read) {
            var recData = socket
                .receive()
                .data;
            print(recData);
          }
        });
      });
      if(streamControl) timer.cancel();
    });
  }
  void turnLightToUDP(){
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
  void openFile(int num){
    //打开存储的灯光配置文件1-10
    if(num>0 && num<11){
      Uint8List sendData = Uint8List(4);
      var data = ByteData.view(sendData.buffer);
      data.setUint8(0, 0x00);
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
  void closeFile(){//关闭当前打开的文件
    if(opendFile!=0){
      Uint8List sendData = Uint8List(4);
      var data = ByteData.view(sendData.buffer);
      data.setUint8(0, 0x00);
      data.setUint8(1, 0x01);
      data.setUint8(2, opendFile+2);
      data.setUint8(3, 0x02);
      setData(4, sendData);
      print("File end.");
      opendFile = 0;
      sendTCP();
    }else{
      print("No File Opening.");
    }
  }
  void testLED(){//执行显示测试，结束后关灯
    //getAmount();//先执行获取灯的数量
    //主要是因为初始化时有概率初始化失败
    print("led amount is: "+LEDamount.toString());

    turnLightToUDP();
    const timeout2 = const Duration(seconds: 4);//2s一次
    int count = 0;
    var rand = Random();
    Uint8List sendData2 = Uint8List(LEDamount*3+5);
    var data2 = ByteData.view(sendData2.buffer);
    data2.setUint8(0, 0x01);
    data2.setUint8(1, 0x00);//从哪开始
    data2.setUint8(2, 0x00);
    data2.setUint8(3, (LEDamount >> 0) & 0xff);//持续多长
    data2.setUint8(4, (LEDamount >> 8) & 0xff);
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
  }

  void sendTCP() async {
    //Uint8List returnMessage;
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    Socket socket = await Socket.connect(LEDaddr, 6600); //TCP
    socket.add(message);//发送数据包
    socket.listen((datarec) {
      //print("TCP return :" + datarec.toString());
    }); //TCPEND
    await socket.flush();
    await socket.close();
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
          print(recData);
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
    Uint8List message2 = Uint8List(9);//发送的数据包包头
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