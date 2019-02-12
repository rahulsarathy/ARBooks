//
//  OpenCVWrapper.h
//  OpenCVForNoobs
//
//  Created by Rahul Sarathy on 1/16/19.
//  Copyright © 2019 Rahul Sarathy. All rights reserved.
//

#import "OpenCVWrapper.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <SceneKit/SceneKit.h>

typedef struct PoseResults2 {
    
    float translation_vector[3];
    float euler_angles[3];
    
} PoseResults2;

typedef struct MarkerPose {
    bool found;
    SCNVector3 tvec;
    SCNVector3 rvec;
    SCNMatrix4 rotMat;
    int id;
} MarkerPose;

@interface OpenCVWrapper : NSObject
- (UIImage *)addAR:(UIImage *)source;
+ (UIImage *)findMarkers:(UIImage *)source;
+ (MarkerPose) findPose:(CVPixelBufferRef)pixelBuffer withIntrinsics:(matrix_float3x3)intrinsics andMarkerSize:(Float64)markerSize imageDownsample:(float)scale;
+(SCNMatrix4) transformMatrixFromPixelBuffer:(CVPixelBufferRef)pixelBuffer withIntrinsics:(matrix_float3x3)intrinsics andMarkerSize:(Float64)markerSize;
+ (void)isThisWorking;
@end

