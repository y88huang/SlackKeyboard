//
//  PersistentStoreManager.h
//  Gicity
//
//  Created by Ken Huang on 2015-07-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataStack.h"

@interface PersistentStoreManager : NSObject

+ (instancetype)sharedInstance;
- (CoreDataStack *)stack;
- (void)performBlockInBackground:(void (^)(NSManagedObjectContext *context))block;

@end
