//
//  ANDataStoreController.h
//  AppApp
//
//  Created by Jeremy Tregunna on 2012-08-24.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <CoreData/CoreData.h>

// ANDataStoreController is a wrapper around Core Data.
@interface ANDataStoreController : NSObject
@property (nonatomic, readonly, strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, readonly, strong) NSManagedObjectModel* managedObjectModel;
@property (nonatomic, readonly, strong) NSPersistentStoreCoordinator* persistentStoreCoordinator;

+ (instancetype)sharedController;

- (void)saveContext;

- (NSArray*)usernamesForString:(NSString*)string;
- (NSArray*)hashtagsForString:(NSString*)string;

@end
