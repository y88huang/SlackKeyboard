//
//  AnimatedImageManager.m
//  SlackGifKeyboard
//
//  Created by Ken Huang on 2015-06-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "AnimatedImageManager.h"
#import "Constant.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UIKit/UIKit.h>
#import "Gif.h"

@interface AnimatedImageManager()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation AnimatedImageManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kGroupIdentifier];
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:@"yyyy-MM-dd_HH_mm_ss"];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    static AnimatedImageManager *manager = nil;
    dispatch_once(&once, ^{
        manager = [[AnimatedImageManager alloc] init];
    });
    return manager;
}

- (NSString *)exportImages:(NSArray *)images
{
    NSDate *date = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"Gif-%@.gif",[self.formatter stringFromDate:date]];
    NSURL *folderURL = [self.url URLByAppendingPathComponent:kGifFolderName];
    
    BOOL directory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderURL.path isDirectory:&directory])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtURL:folderURL withIntermediateDirectories:YES attributes:nil error: &error];
        if (error)
        {
            NSLog(@"ERROR");
        }
    }
    NSURL *actualURL = [folderURL URLByAppendingPathComponent:fileName];
    NSString *exportPath = makeGif(images, actualURL);
    return exportPath;
}

- (NSArray *)getGifs
{
    NSArray *urls = [self getLocalImages];
    NSMutableArray *gifs = [[NSMutableArray alloc] initWithCapacity:10];
    for (NSURL *url in urls)
    {
        Gif *gif = [[Gif alloc] init];
        gif.smallGifURL = url;
        gif.gifURL = url;
        [gifs addObject:gif];
    }
    return gifs;
}

- (NSArray *)getLocalImages
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray * dirContents = [manager contentsOfDirectoryAtURL:[self.url URLByAppendingPathComponent:kGifFolderName]
      includingPropertiesForKeys:@[]
                         options:NSDirectoryEnumerationSkipsHiddenFiles
                           error:nil];
    NSPredicate * fltr = [NSPredicate predicateWithFormat:@"pathExtension='gif'"];
    NSArray * onlyGifs = [dirContents filteredArrayUsingPredicate:fltr];
    return onlyGifs;
}

static NSString *makeGif(NSArray *images, NSURL *exportURL){
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
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)exportURL, kUTTypeGIF, kFrameCount, NULL);
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
    
    NSLog(@"url=%@", exportURL);
    return exportURL.path;
}

@end
