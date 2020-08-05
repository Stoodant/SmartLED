class customPacket {//ver0.2
  int LEDamount = 0;
  Uint8List message;
  int dataLength = 0;
  bool error = false;

  customPacket() {

    getAmount();//获取灯的数量
    print("created.");
  }

  void sendTCP() async {
    //Uint8List returnMessage;
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    Socket socket = await Socket.connect(LEDaddr, 6600); //TCP
    socket.add(message);//发送数据包
    socket.listen((datarec) {
      print(datarec);
    }); //TCPEND
    socket.close();
  }
  void sendUDP(){
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    var udpSocket = RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    udpSocket.then((socket) {
      socket.send(message, LEDaddr, 6000);//发送数据
//      socket.listen((event) {
//        if (event == RawSocketEvent.read) {
//          var recData = socket
//              .receive()
//              .data;
//          returnMessage = recData;
//        }
//      });
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

    return true;
  }
  void getAmount() async {//获取灯的数量，不需要手动调用，实例化时自动调用一次
    Uint8List sendData = Uint8List(1);
    var data = ByteData.view(sendData.buffer);
    data.setUint8(0, 0x00);
    setData(1, sendData);
    Uint8List receiveData;
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");
    try{
      Socket socket = await Socket.connect(LEDaddr, 6600); //TCP
      socket.add(message);//发送数据包
      socket.listen((datarec) {//接受数据包
        receiveData =  datarec;
        var data = ByteData.view(receiveData.buffer);
        if(receiveData[8]==128){
          print(receiveData);
          this.LEDamount = data.getUint8(11);
          this.LEDamount = this.LEDamount << 8;
          this.LEDamount = this.LEDamount | data.getUint8(10);
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