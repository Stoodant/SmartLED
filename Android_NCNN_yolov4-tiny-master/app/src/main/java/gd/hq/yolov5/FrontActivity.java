package gd.hq.yolov5;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

public class FrontActivity extends AppCompatActivity {

    private Button mBtnEdit;
    private Button mBtnCircle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_front);
        mBtnEdit = findViewById(R.id.button2);
        mBtnCircle = findViewById(R.id.button3);
        mBtnEdit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(FrontActivity.this,MainActivity.class);
                startActivity(intent);;
            }
        });

        mBtnCircle.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(FrontActivity.this,EditActivity.class);
                startActivity(intent);
            }
        });
    }
}