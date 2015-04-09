//
//  TBExampleVideoCapture.h
//  OpenTok iOS SDK
//
//  Copyright (c) 2013 Tokbox, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <OpenTok/OpenTok.h>

//#define YUV_FILE_NAME           @"1280_720_HIGH.yuv"
//#define YUV_FILE_NAME_DECODED   @"1280_720_HIGH_Decoded.yuv"

//#define YUV_FILE_NAME           @"640_480_HIGH.yuv"
//#define YUV_FILE_NAME_DECODED   @"640_480_HIGH_Decoded.yuv"

#define YUV_FILE_NAME           @"352_288_HIGH.yuv"
#define YUV_FILE_NAME_DECODED   @"352_288_HIGH_Decoded.yuv"

// 352_288_HIGH.yuv 640_480_HIGH.yuv 1280_720_HIGH.yuv

@protocol OTVideoCapture;

@interface TBExampleVideoCapture : NSObject
    <AVCaptureVideoDataOutputSampleBufferDelegate, OTVideoCapture>
{

    @protected
    dispatch_queue_t _capture_queue;
    
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, retain) AVCaptureDeviceInput *videoInput;

@property (nonatomic, assign) NSString* captureSessionPreset;
@property (readonly) NSArray* availableCaptureSessionPresets;

@property (nonatomic, assign) double activeFrameRate;
- (BOOL)isAvailableActiveFrameRate:(double)frameRate;

@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (readonly) NSArray* availableCameraPositions;

@property (nonatomic, assign) OTSession *session;
@property (nonatomic, assign) int loopCount;

- (BOOL)toggleCameraPosition;

@end
