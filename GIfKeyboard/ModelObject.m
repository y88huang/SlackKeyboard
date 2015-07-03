//
//  ModelObject.m
//  Gicity
//
//  Created by Ken Huang on 2015-07-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import "ModelObject.h"

@implementation ModelObject

+ (id)entityName
{
    return NSStringFromClass([self class]);
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

@end