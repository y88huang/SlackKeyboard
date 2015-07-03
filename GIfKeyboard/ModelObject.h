//
//  ModelObject.h
//  Gicity
//
//  Created by Ken Huang on 2015-07-02.
//  Copyright (c) 2015 Ken Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ModelObject : NSManagedObject

+ (id)entityName;
+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext*)context;

@end
