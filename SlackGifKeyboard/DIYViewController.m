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
#import "AnimatedImageManager.h"
#import "ImageCollectionViewCell.h"
#import "FrameSelectorLayout.h"
#import "UIImage+GIF.h"

static const NSInteger kFrameCount = 6;

typedef NS_ENUM(NSUInteger, RecordingState) {
    RecordingStateOriginal,
    RecordingStateRecording,
    RecordingStateFinished,
};

@interface DIYViewController () <AVCaptureFileOutputRecordingDelegate,
                                    UICollectionViewDataSource,
                                        UICollectionViewDelegate,
                                        UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInputDevice;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMovieFileOutput *output;

@property (nonatomic, strong) UIView *previewScreenView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) NSDateFormatter *formatter;

@property (nonatomic, strong) UIView *frameView;

@property (nonatomic, strong) UICollectionView *selectCollectionView;

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UIImageView *previewGifImageView;

@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation DIYViewController
{
    RecordingState _currentState;
    NSArray *_tmpImages;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentState = RecordingStateOriginal;
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy-MM-dd_HH_mm_ss"];

    [self setupFrameImageView];
    [self setupCaptureSession];
    [self setupCloseButton];
    [self setupCancelButton];
    [self setupPreviewImageView];
    [self setupCollectionView];
}

- (void)setupCloseButton
{
    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    self.closeButton.center = CGPointMake(70.0f, self.recordButton.center.y);
    self.closeButton.backgroundColor = [UIColor turquoise];
    self.closeButton.layer.cornerRadius = 25.0f;
    self.closeButton.layer.borderWidth = 4.0f;
    self.closeButton.layer.borderColor = [UIColor nephritis].CGColor;
    [self.bottomView addSubview:self.closeButton];
    [self.closeButton addTarget:self action:@selector(didPressCloseButton:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)setupFrameImageView
{
    self.frameView = [[UIView alloc] init];
    self.frameView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.frameView];
}

- (void)setupCollectionView
{
    FrameSelectorLayout *flowLayout = [[FrameSelectorLayout alloc] init];
    
    self.selectCollectionView = [[UICollectionView alloc] initWithFrame:self.frameView.bounds collectionViewLayout:flowLayout];
    [self.frameView addSubview:self.selectCollectionView];
    self.selectCollectionView.delegate = self;
    self.selectCollectionView.dataSource = self;
    self.selectCollectionView.backgroundColor = [UIColor orangeColor];
    self.selectCollectionView.bounces = NO;
    self.selectCollectionView.decelerationRate = 0.0f;
    [self.selectCollectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.selectCollectionView.hidden = YES;
}

- (void)setupPreviewImageView
{
    self.previewGifImageView = [[UIImageView alloc] init];
    self.previewGifImageView.frame = self.previewLayer.frame;
    self.previewGifImageView.backgroundColor = [UIColor clearColor];
    self.previewGifImageView.hidden = YES;
    [self.previewScreenView addSubview:self.previewGifImageView];
}

- (void)setupCancelButton
{
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    self.cancelButton.layer.cornerRadius = 25.0f;
    self.cancelButton.center = CGPointMake(self.recordButton.center.x + CGRectGetWidth(self.recordButton.bounds), self.recordButton.center.y);
    [self.bottomView addSubview:self.cancelButton];
    self.cancelButton.backgroundColor = [UIColor amethyst];
    self.cancelButton.layer.borderWidth = 4.0f;
    self.cancelButton.layer.borderColor = [UIColor peterRiver].CGColor;
    [self.cancelButton addTarget:self action:@selector(didPressCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.hidden = YES;
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
    
    self.frameView.frame = CGRectMake(0.0f,
                                      CGRectGetMinY(self.bottomView.frame) - 60.0,
                                      CGRectGetWidth(self.view.bounds),
                                      60.0);
    
    CGFloat buttonHeight = CGRectGetHeight(self.bottomView.bounds) * 0.8f;
    CGRect buttonRect = CGRectMake(0.0f,
                                   0.0f,
                                   buttonHeight,
                                   buttonHeight);
    self.recordButton = [[UIButton alloc] initWithFrame:buttonRect];
    [self.bottomView addSubview: self.recordButton];
    self.recordButton.layer.cornerRadius = buttonHeight / 2.0f;
    self.recordButton.layer.borderWidth = 6.0f;
    self.recordButton.layer.borderColor = [UIColor sunFlower].CGColor;
    self.recordButton.backgroundColor = [UIColor whiteColor];
    self.recordButton.center = CGPointMake(CGRectGetWidth(self.bottomView.bounds) / 2.0f, CGRectGetHeight(self.bottomView.bounds) / 2.0f);
    
    [self.recordButton addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.previewLayer setBounds:layerRect];
    [self.previewLayer setPosition:CGPointMake(CGRectGetMidX(self.view.bounds),
                                          CGRectGetMidY(self.view.bounds) - 20.0f)];
    [[self.previewScreenView layer] addSublayer: self.previewLayer];
//    [self.view bringSubviewToFront:self.recordButton]; // Hides behind preview layer
    
    [[self.previewScreenView layer] addSublayer: self.previewLayer];
    
    [self.session startRunning];
    [self.view bringSubviewToFront:self.frameView];
}

- (void)startRecording:(UIButton *)sender
{
    switch (_currentState)
    {
        case RecordingStateOriginal:
        {
            [self recordVideo];
            _currentState = RecordingStateRecording;
            sender.backgroundColor = [UIColor airbnbPink];
            self.previewGifImageView.hidden = YES;
            self.previewLayer.hidden = NO;
            self.cancelButton.hidden = YES;
            self.selectCollectionView.hidden = YES;
        }
            break;
            
        case RecordingStateRecording:
        {
            _currentState = RecordingStateFinished;
            [self.output stopRecording];
            self.previewLayer.hidden = YES;
            self.previewGifImageView.hidden = NO;
            self.cancelButton.hidden = NO;
            self.selectCollectionView.hidden = NO;
        }
            break;
        case RecordingStateFinished:
        {
            _currentState = RecordingStateOriginal;
            self.cancelButton.hidden = YES;
            [[AnimatedImageManager sharedInstance] exportImages:_tmpImages];
            self.selectCollectionView.hidden = YES;
            self.previewGifImageView.hidden = YES;
            self.previewLayer.hidden = NO;
            self.recordButton.backgroundColor = [UIColor whiteColor];
        }
            break;
    }
}

- (void)recordVideo
{
    NSString *outputPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.mov"];
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
    
    _currentState = RecordingStateRecording;
    
    [self.output startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSIndexPath *currentIndexPath = [self.selectCollectionView indexPathForItemAtPoint:scrollView.contentOffset];
    NSArray *images = [self.images subarrayWithRange:NSMakeRange(currentIndexPath.row, kFrameCount)];
    
    _tmpImages = images;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString *fileString = [[AnimatedImageManager sharedInstance] generateTemperoryPreview:images];
        UIImage *image = [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:fileString]];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.previewGifImageView.image = image;
        });
    });
}

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
        generator.requestedTimeToleranceAfter = kCMTimeZero;
        generator.requestedTimeToleranceBefore = kCMTimeZero;
        generator.appliesPreferredTrackTransform = YES;
        CMTime duration = asset.duration;
        int framePerSec = kFrameCount;
        int totalFrame = floorf(CMTimeGetSeconds(duration)) * framePerSec;

        NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:10];
        for (int i = 0; i < totalFrame; i++){
            CMTime actualTime;
            CMTime time = CMTimeMake(i, (CGFloat)kFrameCount);
            Float64 cm = CMTimeGetSeconds(time);
            NSLog(@"fetching frame at %5f", cm);
            CGImageRef ref = [generator copyCGImageAtTime:time actualTime:&actualTime error:nil];
            NSLog(@"actual time %5f", CMTimeGetSeconds(actualTime));
            UIImage *image = [[UIImage alloc] initWithCGImage:ref];
            [images addObject:image];
            CGImageRelease(ref);
        }
        self.images = images;
        [self.selectCollectionView reloadData];
        NSString *url = [[AnimatedImageManager sharedInstance] exportImages:images];
        self.previewGifImageView.image = [UIImage sd_animatedGIFWithData:[NSData dataWithContentsOfFile:url]];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = self.images[indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(self.view.bounds) / (CGFloat)kFrameCount, CGRectGetHeight(collectionView.bounds));
}

- (void)didPressCancelButton:(UIButton *)button
{
    _currentState = RecordingStateOriginal;
    button.hidden = YES;
    self.recordButton.backgroundColor = [UIColor whiteColor];
    self.selectCollectionView.hidden = YES;
    self.previewLayer.hidden = NO;
    self.previewGifImageView.image = nil;
    self.previewGifImageView.hidden = YES;
}

- (void)didPressCloseButton:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
