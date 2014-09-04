
//
//  EyeTracker.cpp
//  Eye Roll
//
//  Created by Marco Stagni on 01/08/14.
//  Copyright (c) 2014 Marco Stagni. All rights reserved.
//

#include "EyeTracker.h"

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/objdetect/objdetect.hpp>

#include <iostream>
#include <thread>

#include "CoreFoundation/CoreFoundation.h"

#include "AppDelegate.h"


bool canRun = false;
std::thread t;

void l(std::string message) {
    std::cout << message << std::endl;
}

// ----------------------------------------------------------------------------


cv::CascadeClassifier face_cascade;
cv::CascadeClassifier eye_cascade;

/**
 * Function to detect human face and the eyes from an image.
 *
 * @param  im    The source image
 * @param  tpl   Will be filled with the eye template, if detection success.
 * @param  rect  Will be filled with the bounding box of the eye
 * @return zero=failed, nonzero=success
 */
int detectEye(cv::Mat& im, cv::Mat& tpl, cv::Rect& rect)
{
    cv::CascadeClassifier lol;
	std::vector<cv::Rect> faces, eyes;
	face_cascade.detectMultiScale(im, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30,30));
    
	for (int i = 0; i < faces.size(); i++)
	{
		cv::Mat face = im(faces[i]);
		eye_cascade.detectMultiScale(face, eyes, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(20,20));
        
		if (eyes.size())
		{
			rect = eyes[0] + cv::Point(faces[i].x, faces[i].y);
			tpl  = im(rect);
		}
	}
    
	return eyes.size();
}

/**
 * Perform template matching to search the user's eye in the given image.
 *
 * @param   im    The source image
 * @param   tpl   The eye template
 * @param   rect  The eye bounding box, will be updated with the new location of the eye
 */
void trackEye(cv::Mat& im, cv::Mat& tpl, cv::Rect& rect)
{
	cv::Size size(rect.width * 2, rect.height * 2);
	cv::Rect window(rect + size - cv::Point(size.width/2, size.height/2));
    
	window &= cv::Rect(0, 0, im.cols, im.rows);
    
	cv::Mat dst(window.width - tpl.rows + 1, window.height - tpl.cols + 1, CV_32FC1);
	cv::matchTemplate(im(window), tpl, dst, CV_TM_SQDIFF_NORMED);
    
	double minval, maxval;
	cv::Point minloc, maxloc;
	cv::minMaxLoc(dst, &minval, &maxval, &minloc, &maxloc);
    
	if (minval <= 0.2)
	{
		rect.x = window.x + minloc.x;
		rect.y = window.y + minloc.y;
	}
	else
		rect.x = rect.y = rect.width = rect.height = 0;
}

int _track()
{
    
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
    char path[PATH_MAX];
    if (!CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX))
    {
        // error!
    }
    CFRelease(resourcesURL);
    
    chdir(path);
    std::cout << "Current Path: " << path << std::endl;
	// Load the cascade classifiers
	// Make sure you point the XML files to the right path, or
	// just copy the files from [OPENCV_DIR]/data/haarcascades directory
	face_cascade.load("haarcascade_frontalface_alt2.xml");
	eye_cascade.load("haarcascade_eye.xml");
    
	// Open webcam
	cv::VideoCapture cap(0);
    
	// Check if everything is ok
    if (face_cascade.empty()) {
        std::cout << "face cascade empty";
        return 1;
    } else {
        std::cout << "OK face" << std::endl;
    }
    if (eye_cascade.empty()) {
        std::cout << "eye cascade empty";
        return 1;
    } else {
        std::cout << "OK eye" << std::endl;
    }
    if (!cap.isOpened()) {
        std::cout << "cap is not opened";
        return 1;
    } else {
        std::cout << "OK cap" << std::endl;
    }
    l("set up video size");
	// Set video to 320x240
	cap.set(CV_CAP_PROP_FRAME_WIDTH, 320);
	cap.set(CV_CAP_PROP_FRAME_HEIGHT, 240);
    
	cv::Mat frame, eye_tpl;
	cv::Rect eye_bb;
    
    canRun = true;
    
	while (canRun)
	{
        //l("inside while");
		cap >> frame;
		if (frame.empty()) {
            //l("frame empty");
            break;
        } else {
            //l("frame not empty");
        }
		// Flip the frame horizontally, Windows users might need this
		cv::flip(frame, frame, 1);
        //l("after frame flip");
        
		// Convert to grayscale and
		// adjust the image contrast using histogram equalization
		cv::Mat gray;
		cv::cvtColor(frame, gray, CV_BGR2GRAY);
        //l("after grayscale conversion");
        
		if (eye_bb.width == 0 && eye_bb.height == 0)
		{
			// Detection stage
			// Try to detect the face and the eye of the user
            //l("inside detection stage, before detecteye");
			detectEye(gray, eye_tpl, eye_bb);
            //l("inside detection stage, after detecteye");
		}
		else
		{
            //l("inside tracking stage, before trackeye");
			// Tracking stage with template matching
			trackEye(gray, eye_tpl, eye_bb);
            //l("inside tracking stage, after trackeye");
            
			// Draw bounding rectangle for the eye
			//cv::rectangle(frame, eye_bb, CV_RGB(0,255,0));
            l(""+std::to_string(eye_bb.x)+"-"+std::to_string(eye_bb.y)+"");
            //method(NULL, 1, 1);
        }
        
		// Display video
		//cv::imshow("video", frame);
	}
    l("outside while, returning");
    return 0;
}

int startTracking() {
    l("start thread");
    t = std::thread(_track);
    return 0;
}

int stopTracking() {
    l("stopped thread");
    canRun = false;
    return 1;
}

