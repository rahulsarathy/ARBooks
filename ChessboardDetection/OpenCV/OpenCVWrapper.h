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

NS_ASSUME_NONNULL_BEGIN


@interface OpenCVWrapper : NSObject
- (UIImage *)addAR:(UIImage *)source;
- (UIImage *)findMarkers:(UIImage *)source;
- (void)isThisWorking;
@end

NS_ASSUME_NONNULL_END
