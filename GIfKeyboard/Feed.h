//
//  Feed.h
//  Gicity
//
//  Created by Ken Huang on 2015-07-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelObject.h"
@interface Feed : ModelObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSSet *gifs;

+ (Feed *)findOrCreateFeedWithUrl:(NSString *)url inContext:(NSManagedObjectContext *)context;

@end
