#include <iostream>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"

using namespace cv;
using namespace std;

int main(int argc, char** argv)
{
	//VideoCapture cap(0); //capture the video from web cam

	//if (!cap.isOpened())  // if not success, exit program
	//{
	//	cout << "Cannot open the web cam" << endl;
	//	return -1;
	//}

	namedWindow("control", 1);
	int ctrl = 0;
	createTrackbar("ctrl", "control", &ctrl, 7);

	while (true)
	{
		Mat imgOriginal;

		//bool bSuccess = cap.read(imgOriginal); // read a new frame from video
		//if (!bSuccess) //if not success, break loop
		//{
		//	cout << "Cannot read a frame from video stream" << endl;
		//	break;
		//}

		imgOriginal = imread("C:/Users/Administrator/Desktop/c.png");

		Mat imgHSV, imgBGR;
		Mat imgThresholded;

		if (0)
		{
			vector<Mat> hsvSplit;   //创建向量容器，存放HSV的三通道数据
			cvtColor(imgOriginal, imgHSV, COLOR_BGR2HSV); //Convert the captured frame from BGR to HSV
			split(imgHSV, hsvSplit);			//分类原图像的HSV三通道
			equalizeHist(hsvSplit[2], hsvSplit[2]);    //对HSV的亮度通道进行直方图均衡
			merge(hsvSplit, imgHSV);				   //合并三种通道
			cvtColor(imgHSV, imgBGR, COLOR_HSV2BGR);    //将HSV空间转回至RGB空间，为接下来的颜色识别做准备
		}
		else
		{
			imgBGR = imgOriginal.clone();
		}



		switch (ctrl)
		{
		case 0:
		{
			inRange(imgBGR, Scalar(128, 0, 0), Scalar(255, 127, 127), imgThresholded); //蓝色
			//这个函数将BGR图像中满足在(128, 0, 0)与(255, 127, 127)范围内的像素点选出来，并将该范围内的像素值赋值为白色，
			//其他区域赋值为黑色，并将这个二值图像存入 imgThresholded。
			break;
		}
		case 1:
		{
			inRange(imgBGR, Scalar(128, 128, 128), Scalar(255, 255, 255), imgThresholded); //白色
			break;
		}
		case 2:
		{
			inRange(imgBGR, Scalar(128, 128, 0), Scalar(255, 255, 127), imgThresholded); //靛色
			break;
		}
		case 3:
		{
			inRange(imgBGR, Scalar(128, 0, 128), Scalar(255, 127, 255), imgThresholded); //紫色
			break;
		}
		case 4:
		{
			inRange(imgBGR, Scalar(0, 128, 128), Scalar(127, 255, 255), imgThresholded); //黄色
			break;
		}
		case 5:
		{
			inRange(imgBGR, Scalar(0, 128, 0), Scalar(127, 255, 127), imgThresholded); //绿色
			break;
		}
		case 6:
		{
			inRange(imgBGR, Scalar(0, 0, 128), Scalar(127, 127, 255), imgThresholded); //红色
			break;
		}
		case 7:
		{
			inRange(imgBGR, Scalar(0, 0, 0), Scalar(127, 127, 127), imgThresholded); //黑色
			break;
		}
		}

		imshow("形态学去噪声前", imgThresholded);

		Mat element = getStructuringElement(MORPH_RECT, Size(5, 5));
		morphologyEx(imgThresholded, imgThresholded, MORPH_OPEN, element);
		morphologyEx(imgThresholded, imgThresholded, MORPH_CLOSE, element);

		imshow("Thresholded Image", imgThresholded); //show the thresholded image
		imshow("直方图均衡以后", imgBGR);
		imshow("Original", imgOriginal); //show the original image

		char key = (char)waitKey(300);
		if (key == 27)
			break;
	}

	return 0;

}
