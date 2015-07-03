//
//  PersistentStoreManager.m
//  Gicity
//
//  Created by Ken Huang on 2015-07-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "PersistentStoreManager.h"
#import "Constant.h"

@interface PersistentStoreManager ()

@property (nonatomic, strong) CoreDataStack *stack;

@end

@implementation PersistentStoreManager

+ (instancetype)sharedInstance
{
    static PersistentStoreManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PersistentStoreManager alloc] init];
        manager.stack = [[CoreDataStack alloc] initWithStoreURL:[[self class] storeURL] modelURL:[[NSBundle mainBundle] URLForResource:@"GicityCache" withExtension:@"momd"]];
    });
    return manager;
}

+ (NSURL*)storeURL
{
    NSURL *url = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kGroupIdentifier];
    return [url URLByAppendingPathComponent:@"db.sqlite"];
}

- (void)performBlockInBackground:(void (^)(NSManagedObjectContext *))block
{
    [self.stack.backgroundManagedObjectContext performBlock:^{
        block(self.stack.backgroundManagedObjectContext);
    }];
}

- (CoreDataStack *)stack
{
    return _stack;
}

@end
