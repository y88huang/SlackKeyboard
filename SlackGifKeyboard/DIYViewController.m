//
//  DIYViewController.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-05-30.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "DIYViewController.h"
#import "Masonry.h"
#import "UIColor+Flat.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface DIYViewController () <AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInputDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMovieFileOutput *output;

@property (nonatomic, strong) UIView *previewScreenView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic, assign) BOOL isRecording;

@end

@implementation DIYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCaptureSession];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy-MM-dd_HH_mm_ss"];
    self.isRecording = NO;
}

- (void)setupCaptureSession
{
    self.session = [[AVCaptureSession alloc] init];
    
     //Add video input.
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    if (videoDevice)
    {
        NSError *error = nil;
        self.videoInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (!error)
        {
            if ([self.session canAddInput:self.videoInputDevice])
            {
                [self.session addInput:self.videoInputDevice];
            }
        }
    }
    
    //add Audio input.
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (audioInput)
    {
        [self.session addInput:audioInput];
    }
    
    //setup preview.
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    //setup output.
    self.output = [[AVCaptureMovieFileOutput alloc] init];
    
    Float64 TotalSeconds = 60;
    int32_t preferredTimeScale = 30;
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
    self.output.maxRecordedDuration = maxDuration;
    
    self.output.minFreeDiskSpaceLimit = 1024 * 1024; //1mb
    
    if ([self.session canAddOutput:self.output])
    {
        [self.session addOutput:self.output];
    }
    
    //Connection.
    AVCaptureConnection *captureConnection = [self.output connectionWithMediaType:AVMediaTypeVideo];
    
    if ([captureConnection isVideoOrientationSupported])
    {
        AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
        [captureConnection setVideoOrientation:orientation];
    }
    
    //set up image quality
    [self.session setSessionPreset:AVCaptureSessionPresetMedium];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset352x288]){
         [self.session setSessionPreset:AVCaptureSessionPreset352x288];
    }
    
    //setup video screen
    CGRect layerRect = self.view.layer.bounds;
    layerRect.size.height *= 0.7;
    self.previewScreenView = [[UIView alloc] init];
    self.previewScreenView.frame = self.view.bounds;
    self.previewScreenView.backgroundColor = [UIColor turquoise];
    
    self.topView = [[UIView alloc] init];
    self.bottomView = [[UIView alloc] init];
    [self.view addSubview:self.previewScreenView];
    
    [self.previewScreenView addSubview:self.topView];
    [self.previewScreenView addSubview:self.bottomView];
    
    self.topView.frame = CGRectMake(0.0f,
                                       0.0f,
                                       CGRectGetWidth(self.view.bounds),
                                       (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.view.bounds) * 0.7f) / 2.0f - 20.0f);
    self.topView.backgroundColor = [UIColor pumpkin];
    
    self.bottomView.frame = CGRectMake(0.0f,
                                       CGRectGetMaxY(self.topView.frame) + CGRectGetHeight(self.view.bounds) * 0.7f, CGRectGetWidth(self.view.bounds),
                                       CGRectGetHeight(self.view.bounds) * 0.15 + 20.0f);
    self.bottomView.backgroundColor = [UIColor alizarin];
    
    CGFloat buttonHeight = CGRectGetHeight(self.bottomView.bounds) * 0.8f;
    CGRect buttonRect = CGRectMake(0.0f,
                                   0.0f,
                                   buttonHeight,
                                   buttonHeight);
    UIButton *recordButton = [[UIButton alloc] initWithFrame:buttonRect];
    [self.bottomView addSubview:recordButton];
    recordButton.layer.cornerRadius = buttonHeight / 2.0f;
    recordButton.backgroundColor = [UIColor whiteColor];
    recordButton.center = CGPointMake(CGRectGetWidth(self.bottomView.bounds) / 2.0f, CGRectGetHeight(self.bottomView.bounds) / 2.0f);
    
    [recordButton addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.previewLayer setBounds:layerRect];
    [self.previewLayer setPosition:CGPointMake(CGRectGetMidX(self.view.bounds),
                                          CGRectGetMidY(self.view.bounds) - 20.0f)];
    [[self.previewScreenView layer] addSublayer: self.previewLayer];
//    [self.view bringSubviewToFront:self.recordButton]; // Hides behind preview layer
    
    [[self.previewScreenView layer] addSublayer: self.previewLayer];
    
    [self.session startRunning];
}

- (void)startRecording:(UIButton *)sender
{
    if (!self.isRecording)
    {
        [self recordVideo];
    }else {
        [self.output stopRecording];
        self.isRecording = NO;
    }
}

- (void)recordVideo
{
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mov"];
//    NSString *dateString = [self.formatter stringFromDate:[NSDate date]];
//    NSString *videoName = [NSString stringWithFormat:@"Anchor_%@.mp4", dateString];
//    NSString *exportPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoName];
    NSURL *outputURL = [NSURL fileURLWithPath:outputPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:outputPath]) //if file exists at path, remove.
    {
        NSError *error;
        if (![fileManager removeItemAtPath:outputPath error:&error])
        {
               //handle error
        }
    }
    
    self.isRecording = YES;
    
    [self.output startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

//- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
//{
//    
//}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    BOOL successful = YES;
    
    if ([error code] != noErr) {
        //probelm
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            successful = [value boolValue];
        }
    }
    
    if (successful)
    {
        NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mov"];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:outputPath] options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
        CMTime duration = asset.duration;
        int framePerSec = 5;
        int totalFrame = floorf(CMTimeGetSeconds(duration)) * framePerSec;

        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:10];
        for (int i = 0; i < totalFrame; i++){
            CMTime actualTime;
            CMTime time = CMTimeMake(i, 5.0);
            CGImageRef ref = [generator copyCGImageAtTime:time actualTime:&actualTime error:nil];
            UIImage *image = [[UIImage alloc] initWithCGImage:ref];
            [images addObject:image];
            CGImageRelease(ref);
        }
        NSString *path = makeGif(images);
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        UIImage *im = [UIImage animatedImageWithImages:images duration:3.0f];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:im];
        [self.view addSubview:imageView];
    }
}

static NSString *makeGif(NSArray *images){
    NSUInteger const kFrameCount = images.count;
    NSDictionary *fileProperties = @{(__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0
                                             }
                                     };
    NSDictionary *frameProperties = @{
                                      (__bridge id)kCGImagePropertyGIFDictionary: @{
                                              (__bridge id)kCGImagePropertyGIFDelayTime: @0.02f
                                              }
                                      };
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:@"animated.gif"];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    for (NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
            UIImage *image = images[i];
            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }
    CFRelease(destination);
    
    NSLog(@"url=%@", fileURL);
    return fileURL.path;
}

@end
