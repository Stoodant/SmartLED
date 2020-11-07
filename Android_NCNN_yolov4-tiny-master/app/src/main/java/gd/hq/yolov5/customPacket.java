package gd.hq.yolov5;

import java.io.DataOutputStream;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.Socket;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.Random;

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
    int[] result;
    int sbCount = 0;//识别计数
    boolean[] sbLED;
    int[] sbColor;
    int sbAmount = 0;

    public customPacket() throws UnknownHostException {
        address = InetAddress.getByName("192.168.4.1");
    }

    private int[] randomArray(int[] arr){//打乱数组
        int[] arr2 =new int[arr.length];
        int count = arr.length;
        int cbRandCount = 0;// 索引
        int cbPosition;// 位置
        int k =0;
        do{
            Random rand = new Random();
            int r = count - cbRandCount;
            cbPosition = rand.nextInt(r);
            arr2[k++] = arr[cbPosition];
            cbRandCount++;
            arr[cbPosition] = arr[r - 1];// 将最后一位数值赋值给已经被使用的cbPosition
        }while(cbRandCount < count);
        return arr2;
    }
    int[] startShiBie(int LEDAmount,int[] colors){
        /**@param LEDAmount 灯的数量
         * @param colors 长度为3的R，G，B，范围0-0xFF
         * @return 长度为LEDAmount的数组，数组每一位为对应灯的二进制编码
         */
        sbCount = 0;//重置计数
        sbAmount = LEDAmount;
        result = new int[LEDAmount];
        for(int i=0;i<LEDAmount;i++){
            result[i] = i + 12;//12是随便写的起始数字
        }
        result = randomArray(result);//随机打乱
        sbLED = new boolean[LEDAmount];
//        for(int i=0;i<LEDAmount;i++){
//            sbLED[i] = true;
//        }
        sbColor = new int[LEDAmount*3];
        for(int j=0;j<LEDAmount;j++){
            sbColor[j*3] = colors[0];
            sbColor[j*3+1] = colors[1];
            sbColor[j*3+2] = colors[2];
        }

        return result;
    }
    int shiBie(){
        if(sbCount>9||sbCount<0) return -1;//-1 未知错误
        if(sbCount>=0){
            for(int j=0;j<sbAmount;j++){
                if(((result[j] >> (8-sbCount)) & 0x01) == 1){
                    sbLED[j] = true;
                }else{
                    sbLED[j] = false;
                }
            }
        }
        sendAnyLEDData(sbAmount,sbLED,sbColor);
        sendAnyLEDData(sbAmount,sbLED,sbColor);
        System.out.println(Arrays.toString(sbLED));
        sbCount++;
        System.out.println("shibie: !!!!!!!!!!!!!!!!!    "+sbCount);
        if(sbCount == 9){//最后一次返回0
            sbCount = 0;
            System.out.println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!this is the nineth");
            return 0;
        }else{
            return sbCount;//不是最后一次返回一个正数
        }

    }

    byte[] setData(int length, byte dataIn[]){
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
        System.out.println("send.");
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
                    for(int i=0;i<LEDAmount;i++){//set color
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
//                    System.out.println(Arrays.toString(LED));
//                    System.out.println(data.length);
                    sendUDP(setData(LEDAmount*3+5,data));
                } catch (Exception e) {
                    e.printStackTrace();
                }

            }
        }).start();
    }


}
