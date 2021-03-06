
#include "opencv/cv.h"
#include "opencv/highgui.h"
#include <math.h>

/*************************************************************
Program to test basic object recognition and tracking using
OpenCV in a real-time video feed.
It uses the HSV colour space to detect Hue (main position
in colour palette) and Saturation (colour distribution/purity)
of the object which is more robust than using RGB and more
resilient to variations in the ilumination conditions.
**************************************************************/

int main(int argc, char *argv[])
{
	// Define Camera
	CvCapture * captureDevice;

	// Create variables (memory space) for
	// Images used during processing
	IplImage* frame;
	IplImage* hsv;
	IplImage* h;
	IplImage* s;
	IplImage* v;

	// Threshold for hue and saturation values
	// This values can be found empirically (for my apple!)
	// or by analysing the images, etc...
	int hLowThresh = 170;
	int hHighThresh = 180;
	int sLowThresh = 115;
	int sHighThresh = 210;

	// Create handles and titles for interface Windows
	char* win1 = "Camera Image";
	char* win2 = "Binary Image";

	// Variables for iterations
	int i, j;
	// Centroid variables (to define the tag point)
	float sumX, sumY, n;

	// Std dev variables
	CvMemStorage* xsStorage;
	CvSeq* xs;
	CvMemStorage* ysStorage;
	CvSeq* ys;
	CvSeqReader xReader;
	CvSeqReader yReader;
	int val;
	float x,y,meanX, meanY,sigmaX, sigmaY;

	// Keypress variable
	int key = 0;

	// Capture a frame to test that the camera is working
	captureDevice = cvCaptureFromCAM(0);
	if(!captureDevice)
	{
		printf("Error - Camera not found\n");
		return 0;
	}

	// Create and Open the inetrface windows
	cvNamedWindow(win1, CV_WINDOW_AUTOSIZE );
	cvNamedWindow(win2, CV_WINDOW_AUTOSIZE );

	// Add widgets for thresholding (the control bars)
	// these can be used to experiment and try detecting other objects
	// or in different light conditions
	cvCreateTrackbar( "H Low Threhold", win2, &hLowThresh, 180, NULL );
	cvCreateTrackbar( "H High Threhold", win2, &hHighThresh, 180, NULL );
	cvCreateTrackbar( "S Low Threhold", win2, &sLowThresh, 255, NULL );
	cvCreateTrackbar( "S High Threhold", win2, &sHighThresh, 255, NULL );

	// Init images
	hsv = cvQueryFrame(captureDevice);
	h = cvCreateImage(cvSize(hsv->width, hsv->height) , IPL_DEPTH_8U, 1);
	s = cvCreateImage(cvSize(hsv->width, hsv->height) , IPL_DEPTH_8U, 1);
	v = cvCreateImage(cvSize(hsv->width, hsv->height) , IPL_DEPTH_8U, 1);

	// Init storage
	xsStorage = cvCreateMemStorage(0); 
	ysStorage = cvCreateMemStorage(0);

	// Init seq - dynamic memory structure availible in Open CV
	xs = cvCreateSeq(CV_32SC1, sizeof(CvSeq), sizeof(int), xsStorage); 
	ys = cvCreateSeq(CV_32SC1, sizeof(CvSeq), sizeof(int), ysStorage);

	// Main loop. Loop while "Esc" key NOT pressed
	// the program can also be closed with ctrl-C in the DOS window
	while (key != 27)
	{
		// Capture a frame
		frame = cvQueryFrame(captureDevice);

		// Now process the frame
		// ---------------------
		// Convert to HSV
		cvCvtColor(frame, hsv, CV_BGR2HSV);
		// Split into the different channels
		cvSplit(hsv, h, s, v, NULL);

		// Applying the threshold below will produce a binary image the
		// shows either nothing, or the pixels that we consider valid.
		// Threshold the hue channel with the values we have defined
		// for our specific object 
		cvThreshold(h, h, hLowThresh, 255, CV_THRESH_TOZERO);
		cvThreshold(h, h, hHighThresh, 255, CV_THRESH_TOZERO_INV);
		cvThreshold(h, h, 0, 255, CV_THRESH_BINARY);

		// Threshold satuaration channel in the same way
		cvThreshold(s, s, sLowThresh, 255, CV_THRESH_TOZERO);
		cvThreshold(s, s, sHighThresh, 255, CV_THRESH_TOZERO_INV);
		cvThreshold(s, s, 0, 255, CV_THRESH_BINARY);

		// Combine the thresholded channels with logical AND
		// to get a binary image of ONLY the pixels that have BOTH
		// the interesting values of Hue AND Saturation
		cvAnd(h,s,v,NULL);

		// Use erode to clean the image somewhat
		cvErode(v,v,NULL,1);
		// You Could add outlier removal here also ...

		// Calculate centroid of remaining pixels to find central
		// position of where the object might be
		sumX = 0.0;
		sumY = 0.0;
		n = 0.1;
		for(i=0;i<v->width;i++)
		{
			for(j=0;j<v->height;j++)
			{
				if(((uchar*)(v->imageData + v->widthStep*j))[i] == 255)
				{
					sumX = sumX + (float)i;
					cvSeqPush( xs, &i ); 
					sumY = sumY + (float)j;
					cvSeqPush( ys, &j );
					n = n + 1.0;
				}
			}
		}
		meanX = sumX / n;
		meanY = sumY / n;

		// Calculate standard deviation to calculate the region it is
		// likely to be occupying
		sumX = 0.0;
		sumY = 0.0;
		cvStartReadSeq( xs, &xReader, 0 ); 
		for( i = 0; i < xs->total; i++ )
		{
			int val;
			CV_READ_SEQ_ELEM(val, xReader);
			x = (float) val;
			sumX = sumX + (x - meanX) * (x - meanX);
		}
		sigmaX = sqrt(sumX / n);
		cvStartReadSeq( ys, &yReader, 0 ); 
		for( i = 0; i < ys->total; i++ )
		{
			int val;
			CV_READ_SEQ_ELEM(val, yReader);
			y = (float) val;
			sumY = sumY + (y - meanY) * (y - meanY);
		}
		sigmaY = sqrt(sumY / n);

		// Clear dynamic memory
		cvClearSeq(xs);
		cvClearSeq(ys);

		// OPEN CV bug, shouldn't have to do this but only get HSV image if I don't
		frame = cvQueryFrame(captureDevice);

		// Draw likely location of the obejct by circling it with a red elipse
		cvEllipse(frame, cvPoint((int)meanX,(int)meanY), cvSize((int)sigmaX,(int)sigmaY), 0, 0, 360, cvScalar(20,20,255,0), 4, 8, 0);

		// Show the images in the interface windows
		cvShowImage(win1, frame);
		cvShowImage(win2, v);

		// Test for a Key press with a short wait
		key = cvWaitKey(100);
	}

	// Clean up
	cvDestroyWindow(win1);
	cvDestroyWindow(win2);

	// Free dynamic memory
	cvReleaseMemStorage(&xsStorage);
	cvReleaseMemStorage(&ysStorage);

	return 0;
}
