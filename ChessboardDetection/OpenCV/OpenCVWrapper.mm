//
//  OpenCVWrapper.m
//  OpenCVForNoobs
//
//  Created by Rahul Sarathy on 1/16/19.
//  Copyright © 2019 Rahul Sarathy. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import "opencv2/imgproc.hpp"
#import "opencv2/aruco.hpp"
#include <iostream>
#include <vector>

using namespace std;
using namespace cv;

@interface OpenCVWrapper ()

+ (Mat)cvMatFromUIImage:(UIImage *)image;
+ (Mat)cvMatGrayFromUIImage:(UIImage *)image;
+ (UIImage *)UIImageFromCVMat:(Mat)cvMat;

@end


@implementation OpenCVWrapper

+ (Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+ (Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+ (UIImage *)UIImageFromCVMat:(Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (UIImage *)addAR:(UIImage *)source {
    cout << "OpenCV: ";
    //return [OpenCVWrapper UIImageFromCVMat:[OpenCVWrapper cvMatGrayFromUIImage:[OpenCVWrapper //cvMatFromUIImage:source]]];
    Mat cvMat = [OpenCVWrapper cvMatFromUIImage:source];
    int myFont = FONT_HERSHEY_SIMPLEX;
    cv::putText(cvMat, "hello", cv::Point(10,500), myFont, 4, (255,255,255));
    //putText(cvMat, "hello", (10,500), myFont, 4, (255,255,255));
    return [OpenCVWrapper UIImageFromCVMat:cvMat];
    
}

+ (UIImage *)findMarkers:(UIImage *)source {
    Mat original = [OpenCVWrapper cvMatFromUIImage:source];
    Mat output;

    Mat gray;

    cvtColor(original, gray, COLOR_BGR2GRAY);

    vector<int> markerIds;
    vector<vector<Point2f>> markerCorners;

    Ptr<aruco::Dictionary> markerDictionary = getPredefinedDictionary(aruco::DICT_6X6_50);

    Ptr<aruco::DetectorParameters> params = aruco::DetectorParameters::create();

    aruco::detectMarkers(gray, markerDictionary, markerCorners, markerIds, params);
    
    cout << markerIds.size() << std::endl;
    
//    for (int i = 0; i < markerCorners.size(); i++)
//    {
//        for (int j = 0; j < markerCorners[i].size(); j++)
//        {
//            cout << markerCorners[i][j];
//        }
//    }
    
    cv::cvtColor(original, output, COLOR_BGRA2BGR);
    
    aruco::drawDetectedMarkers(output, markerCorners, markerIds, Scalar(0, 255, 0));

    return [OpenCVWrapper UIImageFromCVMat:output];
}

//+(SCNMatrix4) findPose:(CVPixelBufferRef)pixelBuffer withIntrinsics:(matrix_float3x3)intrinsics andMarkerSize:(Float64)markerSize {
//
//    cv::Mat cameraMatrix(3,3,CV_64F);
//    cv::Mat image;
//    vector<vector<Point2f>> markerCorners, rejectedCandidates;
//    vector<int> markerIds;
//    vector<Vec3d> rotationVectors, translationVectors;
//
//    image = [OpenCVWrapper convertPixelBufferToOpenCV:pixelBuffer];
//
//    aruco::DetectorParameters parameters;
//
//    cameraMatrix.at<Float64>(0,0) = intrinsics.columns[0][0];
//    cameraMatrix.at<Float64>(0,1) = intrinsics.columns[1][0];
//    cameraMatrix.at<Float64>(0,2) = intrinsics.columns[2][0];
//    cameraMatrix.at<Float64>(1,0) = intrinsics.columns[0][1];
//    cameraMatrix.at<Float64>(1,1) = intrinsics.columns[1][1];
//    cameraMatrix.at<Float64>(1,2) = intrinsics.columns[2][1];
//    cameraMatrix.at<Float64>(2,0) = intrinsics.columns[0][2];
//    cameraMatrix.at<Float64>(2,1) = intrinsics.columns[1][2];
//    cameraMatrix.at<Float64>(2,2) = intrinsics.columns[2][2];
//
//    //Assume 0 distortions
//    cv::Mat distCoeffs = cv::Mat::zeros(5, 1, CV_64F);
//
//
//    cv::Ptr<cv::aruco::Dictionary> dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_6X6_250);
//
//    aruco::detectMarkers(image, dictionary, markerCorners, markerIds);
//    aruco::estimatePoseSingleMarkers(markerCorners, markerSize, cameraMatrix, distCoeffs, rotationVectors, translationVectors);
//
//    int i = 0;
//    std::vector<int>::iterator it;
//
//    for (i=0, it = markerIds.begin(); it != markerIds.end(); it++,i++)
//    {
//        vector<cv::Point3f> objpoints = markerIds[*it];
//
//        it->get3DPoints(markerSize);
//
//    }
//
//}

+ (MarkerPose) findPose:(CVPixelBufferRef)pixelBuffer withIntrinsics:(matrix_float3x3)intrinsics andMarkerSize:(Float64)markerSize {
    
    cv::Mat intrinMat(3,3,CV_64F);
    cv::Mat projectionMat = cv::Mat::zeros(3,3, CV_64F);

    intrinMat.at<Float64>(0,0) = intrinsics.columns[0][0];
    intrinMat.at<Float64>(0,1) = intrinsics.columns[1][0];
    intrinMat.at<Float64>(0,2) = intrinsics.columns[2][0];
    intrinMat.at<Float64>(1,0) = intrinsics.columns[0][1];
    intrinMat.at<Float64>(1,1) = intrinsics.columns[1][1];
    intrinMat.at<Float64>(1,2) = intrinsics.columns[2][1];
    intrinMat.at<Float64>(2,0) = intrinsics.columns[0][2];
    intrinMat.at<Float64>(2,1) = intrinsics.columns[1][2];
    intrinMat.at<Float64>(2,2) = intrinsics.columns[2][2];
    
    
    vector< int > ids;
    vector< vector< Point2f > > corners, rejected;
    vector< Vec3d > rvecs, tvecs;
    
    MarkerPose result; 
    result.found = false;
    
    Mat image;
    
    Ptr<aruco::DetectorParameters> detectorParams = aruco::DetectorParameters::create();

    detectorParams->cornerRefinementMethod = aruco::CORNER_REFINE_SUBPIX; // do corner refinement in markers
    
    image = [OpenCVWrapper convertPixelBufferToOpenCV:pixelBuffer];

    cv::Ptr<cv::aruco::Dictionary> dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_6X6_250);

    aruco::detectMarkers(image, dictionary, corners, ids, detectorParams, rejected);
    
    bool estimatePose = true;
    
    if(estimatePose && ids.size() > 0) {
        aruco::estimatePoseSingleMarkers(corners, markerSize, intrinMat, cv::noArray(), rvecs, tvecs);
    }
    
    if (ids.size() > 0) {
        if (estimatePose) {
            for (unsigned int i = 0; i < ids.size(); i++)
            {
                result.found = true;
                
                result.tvec = SCNVector3Make(tvecs[i][0], tvecs[i][1], tvecs[i][2]);
                result.rvec = SCNVector3Make(rvecs[i][0], rvecs[i][1], rvecs[i][2]);
                
                Mat expandedR;
                
                Rodrigues(rvecs[i], expandedR);
                
                result.rotMat = SCNMatrix4Identity;
                
                result.id = ids[i];
                
                // x and y swapped, z
                // col 1
                result.rotMat.m11 = -expandedR.at<double>(1,0);
                result.rotMat.m12 = -expandedR.at<double>(0,0);
                result.rotMat.m13 = -expandedR.at<double>(2,0);
                
                // col 2
                result.rotMat.m21 = -expandedR.at<double>(1,1);
                result.rotMat.m22 = -expandedR.at<double>(0,1);
                result.rotMat.m23 = -expandedR.at<double>(2,1);
                
                // col 3
                result.rotMat.m31 = -expandedR.at<double>(1,2);
                result.rotMat.m32 = -expandedR.at<double>(0,2);
                result.rotMat.m33 = -expandedR.at<double>(2,2);
                
                assert(expandedR.type() == CV_64F);
                
                return result;
            }
        }
    }
    
    return result;
    
}

+(cv::Mat)convertPixelBufferToOpenCV:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseaddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    CGFloat width = CVPixelBufferGetWidth(pixelBuffer);
    CGFloat height = CVPixelBufferGetHeight(pixelBuffer);
    
    cv::Mat mat(height, width, CV_8UC1, baseaddress, 0);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return mat;
}

+ (void) isThisWorking {
    cout << "Hey" << endl;
}

@end
