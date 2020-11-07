package gd.hq.yolov5;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.CameraX;
import androidx.camera.core.ImageAnalysis;
import androidx.camera.core.ImageAnalysisConfig;
import androidx.camera.core.ImageProxy;
import androidx.camera.core.Preview;
import androidx.camera.core.PreviewConfig;
import androidx.camera.core.UseCase;
import androidx.core.app.ActivityCompat;
import androidx.lifecycle.LifecycleOwner;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.text.PrecomputedText;
import android.util.Log;
import android.util.Rational;
import android.util.Size;
import android.view.TextureView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.Socket;
import java.net.UnknownHostException;
import java.nio.ByteBuffer;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.Calendar;
import java.util.Random;

import static java.lang.Math.pow;

public class MainActivity extends AppCompatActivity {
    private static final int REQUEST_EXTERNAL_STORAGE = 1;
    private static final int REQUEST_PICK_IMAGE = 2;
    private static String[] PERMISSIONS_STORAGE = {
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };
    private ImageView resultImageView;
    private SeekBar nmsSeekBar;
    private SeekBar thresholdSeekBar;
    private TextView thresholdTextview;
    private TextView tvInfo;
    private double threshold = 0.3, nms_threshold = 0.7;
    private TextureView viewFinder;

    private AtomicBoolean detecting = new AtomicBoolean(false);
    private AtomicBoolean detectPhoto = new AtomicBoolean(false);

    private long startTime = 0;
    private long endTime = 0;
    private int width;
    private int height;

    private Button mBtnCircle;
    private Button mBtnTest;
    private Box[] _res;
    private TextView tv3;
    public int number = 400;
    private int ledNumber;
    public Point[] resPoints;
    int[] startLED;

    public String generateRandomFilename(){
        String RandomFilename = "";
        Random rand = new Random();//生成随机数
        int random = rand.nextInt();

        Calendar calCurrent = Calendar.getInstance();
        int intDay = calCurrent.get(Calendar.DATE);
        int intMonth = calCurrent.get(Calendar.MONTH) + 1;
        int intYear = calCurrent.get(Calendar.YEAR);
        String now = String.valueOf(intYear) + "_" + String.valueOf(intMonth) + "_" +
                String.valueOf(intDay) + "_";

        RandomFilename = now + String.valueOf(random > 0 ? random : ( -1) * random);

        return RandomFilename;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        int permission = ActivityCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        if (permission != PackageManager.PERMISSION_GRANTED) {
            // We don't have permission so prompt the user
            ActivityCompat.requestPermissions(
                    this,
                    PERMISSIONS_STORAGE,
                    REQUEST_EXTERNAL_STORAGE
            );
        }
        YOLOv5.init(getAssets());
        resultImageView = findViewById(R.id.imageView);
        thresholdTextview = findViewById(R.id.valTxtView);
        tvInfo = findViewById(R.id.tv_info);
        nmsSeekBar = findViewById(R.id.nms_seek);
        thresholdSeekBar = findViewById(R.id.threshold_seek);
        tv3 = findViewById(R.id.textView3);

        final String format = "Thresh: %.2f, NMS: %.2f";
        thresholdTextview.setText(String.format(Locale.ENGLISH, format, threshold, nms_threshold));
        nmsSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                nms_threshold = i / 100.f;
                thresholdTextview.setText(String.format(Locale.ENGLISH, format, threshold, nms_threshold));
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        thresholdSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int i, boolean b) {
                threshold = i / 100.f;
                thresholdTextview.setText(String.format(Locale.ENGLISH, format, threshold, nms_threshold));
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        Button inference = findViewById(R.id.button);
        inference.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(Intent.ACTION_PICK);
                intent.setType("image/*");
                startActivityForResult(intent, REQUEST_PICK_IMAGE);
            }
        });

        resultImageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                detectPhoto.set(false);
            }
        });

        viewFinder = findViewById(R.id.view_finder);
        viewFinder.addOnLayoutChangeListener(new View.OnLayoutChangeListener() {
            @Override
            public void onLayoutChange(View view, int i, int i1, int i2, int i3, int i4, int i5, int i6, int i7) {
                updateTransform();
            }
        });

        viewFinder.post(new Runnable() {
            @Override
            public void run() {
                startCamera();
            }
        });

        mBtnTest = findViewById(R.id.button5);
        mBtnTest.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {
                    customPacket cp = new customPacket();
                    boolean[] ledId = new boolean[number];
                    for(Point p :resPoints){
                        for(int i=0;i<number;i++){
                            if(startLED[i] == p.id){
                                ledId[i] = true;
                                break;
                            }
                        }
                    }
                    int[] ledCol = new int[3*number];
                    for(int i = 0;i<number;i++){
                        ledCol[3*i] = 0;
                        ledCol[3*i+1] = 0;
                        ledCol[3*i+2] = 0xff;
                    }
                    cp.sendAnyLEDData(number,ledId,ledCol);

                } catch (UnknownHostException e) {
                    e.printStackTrace();
                }

            }
        });

        mBtnCircle = findViewById(R.id.button4);
        mBtnCircle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //ledNumber = _res.length;

                new Thread(new Runnable(){
                    @Override
                    public void run() {
                        try {
                            Thread.sleep(200);
                            code();
                        } catch (IOException | InterruptedException e) {
                            e.printStackTrace();
                        }
                    }
                }).start();

//                Intent intent = new Intent();
//                Bundle bundle = new Bundle();
//                int len = _res.length;
//                bundle.putString("length",Integer.toString(len));
//
//                for(int i = 0;i < len; i++){
//                    bundle.putString(Integer.toString(i)+"color",Integer.toString(_res[i].getColor()));
//                    bundle.putString(Integer.toString(i)+"x0",Float.toString(_res[i].getX0()));
//                    bundle.putString(Integer.toString(i)+"x1",Float.toString(_res[i].getX1()));
//                    bundle.putString(Integer.toString(i)+"y0",Float.toString(_res[i].getY0()));
//                    bundle.putString(Integer.toString(i)+"y1",Float.toString(_res[i].getY1()));
//                    bundle.putString(Integer.toString(i)+"label",_res[i].getLabel());
//                    bundle.putString(Integer.toString(i)+"label2",Integer.toString(_res[i].getLabel2()));
//                    bundle.putString(Integer.toString(i)+"score",Float.toString(_res[i].getScore()));
//                }
//
////                String tmpFileName = generateRandomFilename();
////                BitmapUtil bmp = new BitmapUtil();
////                bmp.saveBitmap2file(_bitmap,tmpFileName);
////                bundle.putString("bitmap",tmpFileName);
//
//                intent.putExtras(bundle);
//                intent.setClass(MainActivity.this,EditActivity.class);
//
//                //
//                startActivity(intent);
            }
        });
    }

    //讲res转换成point
    private Point[] res2point(Box[] boxes){
        Point[] tmp = new Point[boxes.length];
        for (int i = 0; i < boxes.length;i++){
            float x = (boxes[i].x1 + boxes[i].x0)/2.0f;
            float y = (boxes[i].y1 + boxes[i].y0)/2.0f;
            tmp[i] = new Point(x,y,true);
        }
        return tmp;
    }

    //合并函数，用于矫正两次识别结果点位之间的偏差
    private void merge(Point[] before,Point[] after,double threshold){
        for(int i=0;i<before.length;i++){   //遍历基准点位
            boolean flag = false;           //标志是否找到
            for(int j=0;j<after.length;j++){
                double dis = Math.sqrt(pow(before[i].x0-after[j].x0,2)+pow(before[i].y0-after[j].y0,2));    //识别点与基准点的位置
                if(dis < threshold){    //如果小于阈值
                    flag = true;        //代表找到了点
                    before[i].x0 = (before[i].x0 + after[j].x0)/2.0f;   //修正位置
                    before[i].y0 = (before[i].y0 + after[j].y0)/2.0f;
                    before[i].id = (before[i].id << 1) + 1;             //在编码位置上置为1
                    break;
                }
            }
            if(flag == false){  //如果找不到这个点
                before[i].id = (before[i].id << 1) + 0;     //编码位置置为0
            }
        }
    }


    //判断编码
    private void code() throws UnknownHostException {
        //第一次将全部灯点亮
//        tv3.setText("检测所有的灯");
        //send();
        customPacket cp = new customPacket();
        boolean[] allLED = new boolean[number]; //所有的led
        int[] allColor = new int[3*number];     //随机颜色
        for(int i=0;i<number;i++){      //按照红绿蓝一个个排开
            allLED[i] = true;
            int mod = i%3;
            if(mod == 0){
                allColor[3*i] = 0;
                allColor[3*i+1] = 0xff;
                allColor[3*i+2] = 0;
            }
            else if(mod == 1){
                allColor[3*i] = 0;
                allColor[3*i+1] = 0;
                allColor[3*i+2] = 0xff;
            }
            else{
                allColor[3*i] = 0xff;
                allColor[3*i+1] = 0;
                allColor[3*i+2] = 0;
            }
        }

        cp.sendAnyLEDData(number,allLED,allColor);
        cp.sendAnyLEDData(number,allLED,allColor);
        try {   //延迟
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        //cp.sendAnyLEDData(number,allLED,allColor);
        ledNumber = _res.length;
        System.out.println("_res's length: "+_res.length+"?????????????????????????????????????????????");
        Point[] allPoints = res2point(_res);

        System.out.println("识别出来的灯的总数是："+allPoints.length+"!!!!!!!!!!!!!!!!!!!!!!!");
        for(Point p:allPoints){
            System.out.println(p.x0 +" "+ p.y0 +" "+ p.flag);
        }
//        tv3.setText("开始识别");
        //开始编码
        int[] col = new int[3];
        col[0] = 0xff;
        col[1] = 0;
        col[2] = 0;
        startLED = cp.startShiBie(number,col);

        int num = 0;
        final int[] check = {0};
        for(int i=0;i<9;i++){
            //send();
            num += i;
            new Thread(new Runnable(){
                @Override
                public void run() {
                    int i1 = check[0]++;
                    int pro = cp.shiBie();
                    System.out.println("================================================================runnable2: the xulie is    "+pro);
                    try {
                        Thread.sleep(2000);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }).start();

            try {
                Thread.sleep(1500);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            Point[] tmp = res2point(_res);
            System.out.println("_res's length: "+_res.length+"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            System.out.println("allPoints's length: "+allPoints.length+"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

            System.out.println("tmp's length: "+tmp.length+"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            //tv3.setText("第 "+i+" 次!!!!!!");
            merge(allPoints,tmp,8);
            //tv3.setText("第 "+i+" 次");
        }
        System.out.println("(((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((((("+allPoints.length);
        for(Point p:allPoints){
            if(p != null){
                System.out.println("this is p's id: "+p.id+"!!!!!!!!!!!!!!!!!!===========================================!!!!!!!!!!!!!!!!!!!!!!!!");
            }
        }
        System.out.println(")))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))");
        //tv3.setText(" "+num);
        //tv3.setText("识别结束");
        resPoints = allPoints;
    }

    private void updateTransform() {
        Matrix matrix = new Matrix();
        // Compute the center of the view finder
        float centerX = viewFinder.getWidth() / 2f;
        float centerY = viewFinder.getHeight() / 2f;

        float[] rotations = {0, 90, 180, 270};
        // Correct preview output to account for display rotation
        float rotationDegrees = rotations[viewFinder.getDisplay().getRotation()];

        matrix.postRotate(-rotationDegrees, centerX, centerY);

        // Finally, apply transformations to our TextureView
        viewFinder.setTransform(matrix);
    }

    private void startCamera() {
        CameraX.unbindAll();
        // 1. preview
        PreviewConfig previewConfig = new PreviewConfig.Builder()
                .setLensFacing(CameraX.LensFacing.BACK)
//                .setTargetAspectRatio(Rational.NEGATIVE_INFINITY)  // 宽高比
                .setTargetResolution(new Size(416, 416))  // 分辨率
                .build();

        Preview preview = new Preview(previewConfig);
        preview.setOnPreviewOutputUpdateListener(new Preview.OnPreviewOutputUpdateListener() {
            @Override
            public void onUpdated(Preview.PreviewOutput output) {
                ViewGroup parent = (ViewGroup) viewFinder.getParent();
                parent.removeView(viewFinder);
                parent.addView(viewFinder, 0);

                viewFinder.setSurfaceTexture(output.getSurfaceTexture());
                updateTransform();
            }
        });
        DetectAnalyzer detectAnalyzer = new DetectAnalyzer();
        CameraX.bindToLifecycle((LifecycleOwner) this, preview, gainAnalyzer(detectAnalyzer));

    }


    private UseCase gainAnalyzer(DetectAnalyzer detectAnalyzer) {
        ImageAnalysisConfig.Builder analysisConfigBuilder = new ImageAnalysisConfig.Builder();
        analysisConfigBuilder.setImageReaderMode(ImageAnalysis.ImageReaderMode.ACQUIRE_LATEST_IMAGE);
        analysisConfigBuilder.setTargetResolution(new Size(416, 416));  // 输出预览图像尺寸
        ImageAnalysisConfig config = analysisConfigBuilder.build();
        ImageAnalysis analysis = new ImageAnalysis(config);
        analysis.setAnalyzer(detectAnalyzer);
        return analysis;
    }

    private class DetectAnalyzer implements ImageAnalysis.Analyzer {

        @Override
        public void analyze(ImageProxy image, final int rotationDegrees) {
            if (detecting.get() || detectPhoto.get()) {
                return;
            }
            detecting.set(true);
            startTime = System.currentTimeMillis();
            final Bitmap bitmapsrc = imageToBitmap(image);  // 格式转换
            Thread detectThread = new Thread(new Runnable() {
                @Override
                public void run() {
                    Matrix matrix = new Matrix();
                    matrix.postRotate(rotationDegrees);
                    width = bitmapsrc.getWidth();
                    height = bitmapsrc.getHeight();
                    Bitmap bitmap = Bitmap.createBitmap(bitmapsrc, 0, 0, width, height, matrix, false);
                    Box[] result = YOLOv5.detect(bitmap, threshold, nms_threshold);

                    _res = result;
                    //摄像头运行这一块内容

                    final Bitmap mutableBitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true);
                    Canvas canvas = new Canvas(mutableBitmap);
                    final Paint boxPaint = new Paint();
                    boxPaint.setAlpha(200);
                    boxPaint.setStyle(Paint.Style.STROKE);
                    boxPaint.setStrokeWidth(4 * mutableBitmap.getWidth() / 800);
                    boxPaint.setTextSize(40 * mutableBitmap.getWidth() / 800);
                    for (Box box : result) {
                        boxPaint.setColor(box.getColor());
                        boxPaint.setStyle(Paint.Style.FILL);
                        canvas.drawText(box.getLabel(), box.x0 + 3, box.y0 + 40 * mutableBitmap.getWidth() / 1000, boxPaint);
                        boxPaint.setStyle(Paint.Style.STROKE);
                        canvas.drawRect(box.getRect(), boxPaint);
                    }
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            resultImageView.setImageBitmap(mutableBitmap);
                            detecting.set(false);
                            endTime = System.currentTimeMillis();
                            long dur = endTime - startTime;
                            float fps = (float) (1000.0 / dur);
                            tvInfo.setText(String.format(Locale.CHINESE,
                                    "Size: %dx%d\nTime: %.3f s\nFPS: %.3f",
                                    height, width, dur / 1000.0, fps));
                        }
                    });
                }
            }, "detect");
            detectThread.start();
        }

        private Bitmap imageToBitmap(ImageProxy image) {
            ImageProxy.PlaneProxy[] planes = image.getPlanes();
            ImageProxy.PlaneProxy y = planes[0];
            ImageProxy.PlaneProxy u = planes[1];
            ImageProxy.PlaneProxy v = planes[2];
            ByteBuffer yBuffer = y.getBuffer();
            ByteBuffer uBuffer = u.getBuffer();
            ByteBuffer vBuffer = v.getBuffer();
            int ySize = yBuffer.remaining();
            int uSize = uBuffer.remaining();
            int vSize = vBuffer.remaining();
            byte[] nv21 = new byte[ySize + uSize + vSize];
            // U and V are swapped
            yBuffer.get(nv21, 0, ySize);
            vBuffer.get(nv21, ySize, vSize);
            uBuffer.get(nv21, ySize + vSize, uSize);

            YuvImage yuvImage = new YuvImage(nv21, ImageFormat.NV21, image.getWidth(), image.getHeight(), null);
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            yuvImage.compressToJpeg(new Rect(0, 0, yuvImage.getWidth(), yuvImage.getHeight()), 100, out);
            byte[] imageBytes = out.toByteArray();

            return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
        }

    }


    @Override
    protected void onDestroy() {
        CameraX.unbindAll();
        super.onDestroy();
    }


    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        for (int result : grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                this.finish();
            }
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (data == null) {
            return;
        }
        detectPhoto.set(true);
        Bitmap image = getPicture(data.getData());
        Box[] result = YOLOv5.detect(image, threshold, nms_threshold);
        Bitmap mutableBitmap = image.copy(Bitmap.Config.ARGB_8888, true);

        _res = result;
        //tv3.setText(_bitmap.getHeight()+" "+_bitmap.getWidth());

        Canvas canvas = new Canvas(mutableBitmap);
        final Paint boxPaint = new Paint();
        boxPaint.setAlpha(200);
        boxPaint.setStyle(Paint.Style.STROKE);
        boxPaint.setStrokeWidth(4 * image.getWidth() / 800);
        boxPaint.setTextSize(40 * image.getWidth() / 800);
        for (Box box : result) {
            boxPaint.setColor(box.getColor());
            boxPaint.setStyle(Paint.Style.FILL);
            canvas.drawText(box.getLabel(), box.x0 + 3, box.y0 + 17, boxPaint);
            boxPaint.setStyle(Paint.Style.STROKE);
            canvas.drawRect(box.getRect(), boxPaint);
        }
        resultImageView.setImageBitmap(mutableBitmap);
    }

    public Bitmap getPicture(Uri selectedImage) {
        String[] filePathColumn = {MediaStore.Images.Media.DATA};
        Cursor cursor = this.getContentResolver().query(selectedImage, filePathColumn, null, null, null);
        cursor.moveToFirst();
        int columnIndex = cursor.getColumnIndex(filePathColumn[0]);
        String picturePath = cursor.getString(columnIndex);
        cursor.close();
        Bitmap bitmap = BitmapFactory.decodeFile(picturePath);
        int rotate = readPictureDegree(picturePath);
        return rotateBitmapByDegree(bitmap, rotate);
    }

    public int readPictureDegree(String path) {
        int degree = 0;
        try {
            ExifInterface exifInterface = new ExifInterface(path);
            int orientation = exifInterface.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
            switch (orientation) {
                case ExifInterface.ORIENTATION_ROTATE_90:
                    degree = 90;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_180:
                    degree = 180;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_270:
                    degree = 270;
                    break;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return degree;
    }

    public Bitmap rotateBitmapByDegree(Bitmap bm, int degree) {
        Bitmap returnBm = null;
        Matrix matrix = new Matrix();
        matrix.postRotate(degree);
        try {
            returnBm = Bitmap.createBitmap(bm, 0, 0, bm.getWidth(),
                    bm.getHeight(), matrix, true);
        } catch (OutOfMemoryError e) {
        }
        if (returnBm == null) {
            returnBm = bm;
        }
        if (bm != returnBm) {
            bm.recycle();
        }
        return returnBm;
    }


}
