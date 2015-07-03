//
//  Feed.m
//  Gicity
//
//  Created by Ken Huang on 2015-07-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "Feed.h"
#import "NSDate+util.h"

@implementation Feed
@dynamic date;
@dynamic url;
@dynamic gifs;

+ (Feed *)findOrCreateFeedWithUrl:(NSString *)url inContext:(NSManagedObjectContext *)context
{
    NSDate *yesterday = [NSDate dateForHoursBeforeNow:6];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[[self class] entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@ AND date >= %@", [NSURL URLWithString: url], yesterday];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    
    if (result.count == 0)
    {
        NSFetchRequest *staledDataRequest = [NSFetchRequest fetchRequestWithEntityName:[[self class] entityName]];
        staledDataRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@", [NSURL URLWithString:url]];
        NSError *deletionError = nil;
        NSArray *staledData = [context executeFetchRequest:staledDataRequest error:&deletionError];
        
        if (staledData.count)
        {
            for (Feed *feed in staledData)
            {
                [context deleteObject:feed];
            }
            [context performBlock:^{
                if ([context save:nil])
                {
                    NSLog(@"did successfully removed staled data");
                }
                else
                {
                    NSLog(@"failed removing staled data");
                }
            }];
        }
    }
    if (error){
        NSLog(@"error:%@", error.localizedDescription);
    }
    if (result.lastObject)
    {
        return result.lastObject;
    } else {
        Feed *feed = [self insertNewObjectIntoContext:context];
        feed.url = [NSURL URLWithString:url];
        feed.date = [NSDate date];
        return feed;
    }
}

@end
