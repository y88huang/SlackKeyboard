//
//  NSDate+util.m
//  Gicity
//
//  Created by Ken Huang on 2015-07-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "NSDate+util.h"

@implementation NSDate (util)

+ (NSDate *)tomorrow
{
    NSDate *date = [NSDate date];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setDay:1];
    return [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:date options:0];
}

+ (NSDate *)yesterday
{
    NSDate *date = [NSDate date];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setDay: -1];
    return [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:date options:0];
}

+ (NSDate *)dateForHoursBeforeNow:(NSUInteger)hours
{
    NSDate *date = [NSDate date];
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setHour:-hours];
    return [[NSCalendar currentCalendar] dateByAddingComponents:comp toDate:date options:0];
}

@end
