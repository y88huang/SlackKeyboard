//
//  NSDate+util.h
//  Gicity
//
//  Created by Ken Huang on 2015-07-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (util)

+ (NSDate *)tomorrow;
+ (NSDate *)yesterday;
+ (NSDate *)dateForHoursBeforeNow:(NSUInteger)hours;

@end
