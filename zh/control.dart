class customPacket {//ver0.1
  Uint8List message;
  Uint8List message2;
  customPacket() {
    int dataLength = 14;
    int jiaoyan = 0;

    int controlData = 0x01;
    message = Uint8List(dataLength + 8);
    var data = ByteData.view(message.buffer);
    int num = 0x53485955;
    data.setUint32(0, num);
    data.setUint8(4, ((dataLength >> 0) & 0xff));
    data.setUint8(5, ((dataLength >> 8) & 0xff));
    data.setUint8(8, controlData);
    data.setUint8(9, 0x03);
    data.setUint8(10, 0x00);
    data.setUint8(11, 0x03);
    data.setUint8(12, 0x00);
    data.setUint8(13, 0xaa);
    data.setUint8(14, 0x00);
    data.setUint8(15, 0x00);
    data.setUint8(16, 0x00);
    data.setUint8(17, 0xaa);
    data.setUint8(18, 0x00);
    data.setUint8(19, 0x00);
    data.setUint8(20, 0x00);
    data.setUint8(21, 0xaa);
    for (int i = 8; i < 8 + dataLength; i++) {
      jiaoyan += data.getUint8(i);
    }
    int jiaoyan2 = 0xff - (jiaoyan & 255);
    data.setUint8(6, jiaoyan);
    data.setUint8(7, jiaoyan2);

    int dataLength2 = 4;
    int jiaoyan3 = 0;

    int controlData2 = 0x01;
    message2 = Uint8List(dataLength2 + 8);
    var data2 = ByteData.view(message2.buffer);
    int num2 = 0x53485955;
    data2.setUint32(0, num2);
    data2.setUint8(4, ((dataLength2 >> 0) & 0xff));
    data2.setUint8(5, ((dataLength2 >> 8) & 0xff));
    data2.setUint8(8, controlData2);
    data2.setUint8(9, 0x01);
    data2.setUint8(10, 0x01);
    data2.setUint8(11, 0x01);
    for (int i = 8; i < 8 + dataLength2; i++) {
      jiaoyan3 += data2.getUint8(i);
    }
    int jiaoyan22 = 0xff - (jiaoyan3 & 255);
    data2.setUint8(6, jiaoyan3);
    data2.setUint8(7, jiaoyan22);

  }

  Future<Uint8List> sendTCP() async {
    Uint8List returnMessage;
    InternetAddress LEDaddr = InternetAddress("192.168.4.1");


    Socket socket = await Socket.connect(LEDaddr, 6600); //TCP

    print("tcp向Server发送数据");
    socket.add(message2);
    print("tcp向Server发送完成");
    socket.listen((datarec) {
      returnMessage = datarec;
    }); //TCPEND
    socket.close();

    var udpSocket = RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);

    udpSocket.then((socket) {
      socket.send(message, LEDaddr, 6000);
      print("向Server发送数据");
//      socket.listen((event) {
//        if (event == RawSocketEvent.read) {
//          var recData = socket
//              .receive()
//              .data;
//          returnMessage = recData;
//        }
//      });
    }); //UDPEND
    return returnMessage;
  }
}