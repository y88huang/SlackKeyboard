//
//  CoreDataStack.h
//  Gicity
//
//  Created by Ken Huang on 2015-07-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataStack : NSObject

- (id)initWithStoreURL:(NSURL*)storeURL modelURL:(NSURL*)modelURL;

@property (nonatomic,readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,readonly) NSManagedObjectContext* backgroundManagedObjectContext;

@end
