package gd.hq.yolov5;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.Socket;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class heartBeat{
    byte data[] = new byte[9];
    ScheduledExecutorService heartBeatThreadPool;
    Socket heartSocket;
    DataOutputStream  send;
    BufferedReader receive;
    boolean running = false;
    Runnable runnable2 = new Runnable()  {
        @Override
        public void run(){
            //xx++;
            if(running){
                try {
                    send.write(data);
                    System.out.println("finish send data");
//                    String info = receive.readLine();
//                    byte outbyte[] = info.getBytes();
//                    System.out.println(outbyte);
                } catch (IOException e) {
                    running = false;
                    System.out.println("end.");
                    e.printStackTrace();
                }
            }

        }
    };
    heartBeat(){//setup
        data[0] = (byte)0x53;
        data[1] = (byte)0x48;
        data[2] = (byte)0x59;
        data[3] = (byte)0x55;
        data[4] = (byte)0x01;
        data[5] = (byte)0x00;
        data[6] = (byte)0x01;
        data[7] = (byte)0xFE;
        data[8] = (byte)0x06;
    }
    void startHeartBeat(){
        running = true;
        heartBeatThreadPool = Executors.newScheduledThreadPool(3);
        new Thread(new Runnable(){
            @Override
            public void run() {
                try {
                    heartSocket = new Socket("192.168.4.1",6600);
                    send = new DataOutputStream(heartSocket.getOutputStream());
//                    receive = new BufferedReader(new InputStreamReader(heartSocket.getInputStream()));
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }).start();

        heartBeatThreadPool.scheduleAtFixedRate(runnable2, 1, 3, TimeUnit.SECONDS);
    }
    void endHeartBeat(){
        running = false;
        heartBeatThreadPool.shutdown();
    }
}

