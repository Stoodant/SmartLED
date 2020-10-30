package gd.hq.yolov5;

import java.io.DataOutputStream;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Arrays;

public class customPacket{
    int message;
    int streamMessage;
    int streamNo = 0;
    int dataLength = 0;
    boolean error = false;
    int openedFile = 0;
    boolean streamControl = false;
    int totalMemory = 0;
    int usedMemory = 0;
    InetAddress address;

    public customPacket() throws UnknownHostException {
        address = InetAddress.getByName("192.168.4.1");
    }

    byte[] setData(int length,byte dataIn[]){
        byte[] returnData = new byte[length+8];
        if(length >1380){
            returnData[0] = (byte)0xff;
            return returnData;
        }
        for(int i=0;i<length;i++){//填充数据
            returnData[i+8] = dataIn[i];
        }
        returnData[0] = (byte)0x53;
        returnData[1] = (byte)0x48;
        returnData[2] = (byte)0x59;
        returnData[3] = (byte)0x55;
        returnData[4] = (byte)(length & 0xff);
        returnData[5] = (byte)((length >> 8) & 0xff);
        int check = 0;//校验
        for (int i = 0; i < length; i++) {
            check += dataIn[i];
        }
        check = check & 0xff;//低8位
        returnData[6] = (byte)(check & 0xff);
        returnData[7] = (byte)(0xff-check);
        return returnData;
    }

    void sendUDP(byte[] inData){
        if(inData.length > 1472) return;
//        System.out.println(Arrays.toString(inData));
//        System.out.println(inData.length);
        new Thread(new Runnable(){
            @Override
            public void run() {
                try {
                    DatagramPacket packet = new DatagramPacket(inData,inData.length,address,6000);
                    DatagramSocket socketUDP = new DatagramSocket();
                    socketUDP.send(packet);
                    socketUDP.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }

    void sendAnyLEDData(int LEDAmount,boolean LED[],int color[]){
        /**@param LEDAmount 灯的数量
         * @param LED 灯是否发光
         * @param color 颜色数值,rgb三个数一组,0-0xFF,大小为LEDAmount*3
         */
        new Thread(new Runnable(){
            @Override
            public void run() {
                try {

                    byte[] data = new byte[LEDAmount*3+5];
                    data[0] = (byte)0x01;
                    data[1] = (byte)0x00;
                    data[2] = (byte)0x00;
                    data[3] = (byte)((LEDAmount)&0xff);
                    data[4] = (byte)((LEDAmount>>8)&0xff);
                    for(int i=0;i<LEDAmount;i=i+1){//set color
                        if(LED[i]){
                            data[i*3+5] = (byte)color[i*3];//r
                            data[i*3+6] = (byte)color[i*3+1];//g
                            data[i*3+7] = (byte)color[i*3+2];//b
                        }else{
                            data[i*3+5] = 0;//r
                            data[i*3+6] = 0;//g
                            data[i*3+7] = 0;//b
                        }
                    }
                    //System.out.println(Arrays.toString(data));
                    //System.out.println(data.length);
                    sendUDP(setData(LEDAmount*3+5,data));
                } catch (Exception e) {
                    e.printStackTrace();
                }

            }
        }).start();
    }
}
