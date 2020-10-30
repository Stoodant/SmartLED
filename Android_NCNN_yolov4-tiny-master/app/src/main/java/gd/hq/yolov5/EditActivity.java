package gd.hq.yolov5;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.os.Bundle;
import android.widget.TextView;

public class EditActivity extends AppCompatActivity {

    private TextView show;
    private static String[] labels={"r", "g", "b"};

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit);

        show = findViewById(R.id.textView2);

        Bundle bundle2 = this.getIntent().getExtras();
        String tlen = bundle2.getString("length");

        int len = Integer.parseInt(tlen);
        Box[] getRes=new Box[len];
        Integer[] col=new Integer[len];
        for(int i= 0; i < len; i++){
            String tx0 = bundle2.getString(Integer.toString(i)+"x0");
            String tx1 = bundle2.getString(Integer.toString(i)+"x1");
            String ty0 = bundle2.getString(Integer.toString(i)+"y0");
            String ty1 = bundle2.getString(Integer.toString(i)+"y1");
            String tcolor = bundle2.getString(Integer.toString(i)+"color");
            String tlabel = bundle2.getString(Integer.toString(i)+"label2");
            String tscore = bundle2.getString(Integer.toString(i)+"score");
            //show.setText(tx0+" "+tx1+" "+ty0+" "+ty1+" "+tcolor+" "+tlabel+" "+tscore);
            //getRes[i].setScore(Float.parseFloat(tscore));
            getRes[i]=new Box(Float.parseFloat(tx0),Float.parseFloat(ty0),Float.parseFloat(tx1),
                    Float.parseFloat(ty1),Integer.parseInt(tlabel),Float.parseFloat(tscore));
            col[i]=Integer.parseInt(tcolor);
        }

//        BitmapUtil bmp = new BitmapUtil();
//        String tmp = bundle2.getString("bitmap");
//        Bitmap mutableBitmap = bmp.getBitmapFromFile(tmp);
        Bitmap b = Bitmap.createBitmap(256,256,Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(b);
        final Paint boxPaint = new Paint();
        boxPaint.setAlpha(200);
        boxPaint.setStyle(Paint.Style.STROKE);
        boxPaint.setStrokeWidth(4 * 256 / 800);
        boxPaint.setTextSize(40 * 256 / 800);
        for (Box box : getRes) {
            boxPaint.setColor(box.getColor());
            boxPaint.setStyle(Paint.Style.FILL);
            canvas.drawText(box.getLabel(), box.x0 + 3, box.y0 + 40 * 256 / 1000, boxPaint);
            boxPaint.setStyle(Paint.Style.STROKE);
            canvas.drawRect(box.getRect(), boxPaint);
        }

    }
}