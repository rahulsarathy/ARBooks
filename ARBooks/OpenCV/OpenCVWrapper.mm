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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <CoreVideo/CoreVideo.h>

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
    
    cv::cvtColor(original, output, COLOR_BGRA2BGR);
    
    aruco::drawDetectedMarkers(output, markerCorners, markerIds, Scalar(0, 255, 0));

    return [OpenCVWrapper UIImageFromCVMat:output];
}



+(SCNMatrix4) transformMatrixFromPixelBuffer:(CVPixelBufferRef)pixelBuffer withIntrinsics:(matrix_float3x3)intrinsics andMarkerSize:(Float64)markerSize {

    cv::Mat intrinMat(3,3,CV_64F);
    cv::Mat distMat(3,3,CV_64F);
    
    intrinMat.at<Float64>(0,0) = intrinsics.columns[0][0];
    intrinMat.at<Float64>(0,1) = intrinsics.columns[1][0];
    intrinMat.at<Float64>(0,2) = intrinsics.columns[2][0];
    intrinMat.at<Float64>(1,0) = intrinsics.columns[0][1];
    intrinMat.at<Float64>(1,1) = intrinsics.columns[1][1];
    intrinMat.at<Float64>(1,2) = intrinsics.columns[2][1];
    intrinMat.at<Float64>(2,0) = intrinsics.columns[0][2];
    intrinMat.at<Float64>(2,1) = intrinsics.columns[1][2];
    intrinMat.at<Float64>(2,2) = intrinsics.columns[2][2];
    
    distMat.at<Float64>(0,0) = 0;
    distMat.at<Float64>(0,1) = 0;
    distMat.at<Float64>(0,2) = 0;
    distMat.at<Float64>(0,3) = 0;
    
    cv::Ptr<cv::aruco::Dictionary> dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_6X6_250);
    
    Mat image;
    image = [OpenCVWrapper convertPixelBufferToOpenCV:pixelBuffer];
    
    std::vector<int> ids;
    std::vector<std::vector<cv::Point2f>> corners;
    cv::aruco::detectMarkers(image,dictionary,corners,ids);
    
    if (ids.size() > 0 )
    {
        std::vector<cv::Vec3d> rvecs, tvecs;
        cv::Mat distCoeffs = cv::Mat::zeros(8, 1, CV_64F); //zero out distortion for now
        cv::aruco::estimatePoseSingleMarkers(corners, markerSize, intrinMat, distCoeffs, rvecs, tvecs);
        
        cv::Mat rotMat;
        cv::Rodrigues(rvecs[0], rotMat);
        cv::Mat extrinsics(4, 4, CV_64F);

        for( int row = 0; row < rotMat.rows; row++) {
            for (int col = 0; col < rotMat.cols; col++) {
                extrinsics.at<double>(row,col) = rotMat.at<double>(row,col); //copy rotation matrix values
            }
            extrinsics.at<double>(row,3) = tvecs[0][row];
        }
        extrinsics.at<double>(3,3) = 1;
        
        extrinsics = [OpenCVWrapper GetCVToGLMat] * extrinsics;
        return [OpenCVWrapper transformToSceneKitMatrix:extrinsics];
    }
    
    return SCNMatrix4Identity;
}

// Note that in openCV z goes away the camera (in openGL goes into the camera)
// and y points down and on openGL point up
+(cv::Mat) GetCVToGLMat {
    cv::Mat cvToGL = cv::Mat::zeros(4,4,CV_64F);
    cvToGL.at<double>(0,0) = 1.0f;
    cvToGL.at<double>(1,1) = -1.0f; //invert y
    cvToGL.at<double>(2,2) = -1.0f; //invert z
    cvToGL.at<double>(3,3) = 1.0f;
    return cvToGL;
}

+(SCNMatrix4) transformToSceneKitMatrix:(cv::Mat&) openCVTransformation {
    SCNMatrix4 mat = SCNMatrix4Identity;
    
    //Transpose (think this is to switch from col order to row order matrix)
    openCVTransformation = openCVTransformation.t();
    
    //copy rotation rows
    // copy the rotationRows
    mat.m11 = (float) openCVTransformation.at<double>(0, 0);
    mat.m12 = (float) openCVTransformation.at<double>(0, 1);
    mat.m13 = (float) openCVTransformation.at<double>(0, 2);
    mat.m14 = (float) openCVTransformation.at<double>(0, 3);
    
    mat.m21 = (float)openCVTransformation.at<double>(1, 0);
    mat.m22 = (float)openCVTransformation.at<double>(1, 1);
    mat.m23 = (float)openCVTransformation.at<double>(1, 2);
    mat.m24 = (float)openCVTransformation.at<double>(1, 3);
    
    mat.m31 = (float)openCVTransformation.at<double>(2, 0);
    mat.m32 = (float)openCVTransformation.at<double>(2, 1);
    mat.m33 = (float)openCVTransformation.at<double>(2, 2);
    mat.m34 = (float)openCVTransformation.at<double>(2, 3);
    
    //copy the translation row
    mat.m41 = (float)openCVTransformation.at<double>(3, 0);
    mat.m42 = (float)openCVTransformation.at<double>(3, 1);
    mat.m43 = (float)openCVTransformation.at<double>(3, 2);
    mat.m44 = (float)openCVTransformation.at<double>(3, 3);
    
    return mat;
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
