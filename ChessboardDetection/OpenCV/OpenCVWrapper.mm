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
    
    //parameters =
}

- (UIImage *)findMarkers:(UIImage *)source {

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

- (void) isThisWorking {
    cout << "Hey" << endl;
}
@end
