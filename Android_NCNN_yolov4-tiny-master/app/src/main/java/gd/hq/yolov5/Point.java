package gd.hq.yolov5;

public class Point{
    public float x0,y0;
    public boolean flag = false;
    public int id = 0;
    public Point(float x0,float y0){
        this.x0 = x0;
        this.y0 = y0;
    }
    public Point(float x0,float y0,boolean flag){
        this.x0 = x0;
        this.y0 = y0;
        this.flag = flag;
    }
    public void setFlag(boolean flag){
        this.flag = flag;
    }
    public void setId(int id){
        this.id = id;
    }
}
