#include<tchar.h>
#include <stdio.h>
#include <iostream>  
#include <opencv2/core/core.hpp>  
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace std;
using namespace cv;

double GetP2PDis(Point2d p1, Point2d p2);
//int FuncCountHSV(Mat mat);

int _tmain(int argc, _TCHAR* argv[])
{
	Mat img = imread("C:/Users/Administrator/Desktop/d.png");
	Mat imgSrc;
	img.copyTo(imgSrc);

	double time0 = static_cast<double>(getTickCount());    //起始时间

	const Size size = img.size();
	int height = size.height;
	int width = size.width;

	//---To HSV---//
	Mat hsv = Mat::zeros(height, width, CV_8UC3);
	cvtColor(imgSrc, hsv, CV_RGB2HSV);

	//---分离通道---//
	vector<cv::Mat> mv;
	Mat hsv_h = Mat::zeros(height, width, CV_8UC1);
	Mat hsv_s = Mat::zeros(height, width, CV_8UC1);
	Mat hsv_v = Mat::zeros(height, width, CV_8UC1);

	split(hsv, mv);
	hsv_h = mv.at(0);
	hsv_s = mv.at(1);
	hsv_v = mv.at(2);

	//---S-处理---//
	Mat matS1 = Mat::zeros(height, width, CV_8UC1);
	Mat matS2 = Mat::zeros(height, width, CV_8UC1);
	Mat matS3 = Mat::zeros(height, width, CV_8UC1);
	Mat element_Se = getStructuringElement(MORPH_ELLIPSE, Size(5, 5));
	Mat element_Sd = getStructuringElement(MORPH_ELLIPSE, Size(5, 5));
	threshold(hsv_s, matS1, 90, 255, CV_THRESH_BINARY);
	erode(matS1, matS2, element_Se);
	dilate(matS2, matS3, element_Sd);

	//---V-处理---//
	Mat matV1 = Mat::zeros(height, width, CV_8UC1);
	threshold(hsv_v, matV1, 248, 255, CV_THRESH_BINARY);

	//---叠加----//
	Mat matAdd = Mat::zeros(height, width, CV_8UC1);
	add(matS3, matV1, matAdd);

	Mat imgDst = matAdd;
	vector<vector<Point> > contours;
	vector<Vec4i> hierarchy;//轮廓的拓扑结构

	//提取轮廓，轮廓是构成曲线的点，在提取轮廓时，最后采用二值化图像，以及做阈值化处理
	findContours(imgDst, contours, hierarchy, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE, Point(0, 0));

	size_t nContoursNum = contours.size();
	cout << "轮廓数量：" << nContoursNum << endl;

	namedWindow("Test1", 0);
	resizeWindow("Test1", 300, 200);

	size_t RstNum = 0;
	for (size_t index = 0; index < nContoursNum; index++)
	{
		size_t nPerSum = contours[index].size();//计算轮廓构成的图形数量
		double dPerimeter = 0.0;  // 轮廓周长

		for (size_t i = 0; i < nPerSum; i++)
		{
			//----计算周长----//
			double dCurDis = 0.0;
			if (i < nPerSum - 1)
			{
				dCurDis = GetP2PDis(contours[index].at(i), contours[index].at(i + 1));
			}
			else
			{
				dCurDis = GetP2PDis(contours[index].at(i), contours[index].at(0));
			}
			dPerimeter += dCurDis;
		}

		if (dPerimeter > 100)//如果轮廓周长大于100，就将其视为一个圆
		{
			
			//-----计算中心坐标-----//
			int nMinX = contours[index].at(0).x;
			int nMinY = contours[index].at(0).y;
			int nMaxX = contours[index].at(0).x;
			int nMaxY = contours[index].at(0).y;

			double dSumH = 0.0;
			for (size_t i = 1; i < nPerSum; i++)
			{
				if (contours[index].at(i).x > nMaxX) nMaxX = contours[index].at(i).x;
				if (contours[index].at(i).y > nMaxY) nMaxY = contours[index].at(i).y;
				if (contours[index].at(i).x < nMinX) nMinX = contours[index].at(i).x;
				if (contours[index].at(i).y < nMinY) nMinY = contours[index].at(i).y;

				//dSumH += imgSrc.ptr<uchar>(contours[index].at(i).y)[contours[index].at(i).x];
			}

			Point center;
			center.x = nMinX + (nMaxX - nMinX) / 2;
			center.y = nMinY + (nMaxY - nMinY) / 2;
			//cout << "Num: " << RstNum << " Points" << nPerSum << " Length:" << dPerimeter;
			cout << "----X:" << center.x << " Y:" << center.y << endl;

			//------统计颜色-----//
			int colWidth = (nMaxX - nMinX);
			int colHeight = (nMaxY - nMinY);

			Mat matColorH = Mat::zeros(colWidth, colHeight, CV_8UC1);
			Mat matColorS = Mat::zeros(colWidth, colHeight, CV_8UC1);
			Mat matColorV = Mat::zeros(colWidth, colHeight, CV_8UC1);

			Rect rectROI(nMinX, nMinY, colWidth, colHeight);
			hsv_h(rectROI).convertTo(matColorH, matColorH.type(), 1, 0);
			hsv_s(rectROI).convertTo(matColorS, matColorS.type(), 1, 0);
			hsv_v(rectROI).convertTo(matColorV, matColorV.type(), 1, 0);


			Scalar mean_h = mean(matColorH);
			Scalar mean_s = mean(matColorS);
			Scalar mean_v = mean(matColorV);
			double dH = mean_h[0];
			double dS = mean_s[0];
			double dV = mean_v[0];

			//排除黑色物体的干扰
			if (dH > 0 && dH < 180 && dS>0 && dS < 255 && dV>0 && dV < 46) continue;//黑色排除
			if (dH > 0 && dH < 180 && dS>0 && dS < 43 && dV>46 && dV < 220)continue;//灰色排除
			if (dH > 0 && dH < 180 && dS>0 && dS < 43 && dV>221 && dV < 255) continue;//白色排除

			RstNum++;

			//输出HSV数据
			//cout << "H:" << dH << " S:" << dS << " V:" << dV;


			//尝试扩大识别区域，把所有色域划分为三原色，红绿蓝
			if (dH > 0 && dH < 180)
			{
				if (dH > 0 && dH <= 10) cout << "红色 ";
				if (dH > 10 && dH <= 25) cout << "橙色 ";
				if (dH > 25 && dH <= 34) cout << "黄色 ";
				if (dH > 34 && dH <= 77) cout << "绿色 ";
				if (dH > 77 && dH <= 99) cout << "青色 ";
				if (dH > 99 && dH <= 124) cout << "蓝色 ";
				if (dH > 124 && dH <= 155) cout << "紫色 ";
				if (dH > 155 && dH <= 180) cout << "红色 ";

			}
			cout << endl;
			cout << endl;

			//imshow("Test1", matColorH);
			//waitKey();
			//imshow("Test1", matColorS);
			//waitKey();
			//imshow("Test1", matColorV);
			//waitKey();


						//----绘制结果轮廓----//
			Scalar color(rand() & 255, rand() & 255, rand() & 255);
			drawContours(imgSrc, contours, index, color, 1, 8, hierarchy);
			//-----------输出图像，轮廓对象，轮廓索引，绘制颜色，绘制线宽，绘制线的类型，拓扑结构图
			circle(imgSrc, center, 3, color, 5, 8, 0);
			//-----------输出图像，圆心，圆半径，圆颜色，线宽，线的类型
			char str_i[10];
			sprintf_s(str_i, "%d", RstNum);
			putText(imgSrc, str_i, center, CV_FONT_HERSHEY_COMPLEX, 1, Scalar(0, 255, 0), 2, 8);
			imwrite("result.bmp", imgSrc);
		}
	}
	time0 = ((double)getTickCount() - time0) / getTickFrequency();    //运行后时间
	cout << "Run time : " << time0 << endl;


	 imshow("hsv", hsv);
	 waitKey();
	 imshow("hsv_h", hsv_h);
	 waitKey();
	 imshow("hsv_s", hsv_s);
	 waitKey();
	 imshow("hsv_v", hsv_v);
	 waitKey();
	 
	 imshow(" matS1", matS1);
	 waitKey();
	 imshow(" matS2", matS2);
	 waitKey();
	 imshow(" matS3", matS3);
	 waitKey();
	 
	 imshow("matV1", matV1);
	 waitKey();

	 imshow("matAdd", matAdd);
	 waitKey();
	 imshow("imgDst", imgDst);
	 waitKey();

	 //imshow("Test1", matV2);
	 //waitKey();
	 //imshow("Test1", matV3);
	 //waitKey();
	 imshow("imgSrc", img);
	 imshow("imgSrc", imgSrc);
	 waitKey();

	return 0;
}

double GetP2PDis(Point2d p1, Point2d p2)
{
	double dDis = 0.0;
	dDis = sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y));
	return dDis;
}