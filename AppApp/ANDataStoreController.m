//
//  ANDataStoreController.m
//  AppApp
//
//  Created by Jeremy Tregunna on 2012-08-24.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANDataStoreController.h"
#import "ReferencedEntity.h"

@implementation ANDataStoreController

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Object lifecycle

+ (instancetype)sharedController
{
    static ANDataStoreController* shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init
{
    if((self = [super init]))
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveContext) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveContext) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

#pragma mark - Operations on objects

- (void)saveContext
{
    NSError* error = nil;
    if(self.managedObjectContext)
    {
        if([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error])
            NSLog(@"Unresolved Core Data error: %@, %@", error, [error userInfo]);
    }
}

#pragma mark - Searching

- (NSArray*)usernamesForString:(NSString*)string
{
    return [self referencedEntitiesOfType:ANReferencedEntityTypeUsername forString:string];
}

- (NSArray*)hashtagsForString:(NSString*)string
{
    return [self referencedEntitiesOfType:ANReferencedEntityTypeHashtag forString:string];
}

- (NSArray*)referencedEntitiesOfType:(ANReferencedEntityType)type forString:(NSString*)string
{
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"ReferencedEntity" inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(type == %d) AND (name contains[cd] %@)", type, string]];
    // Maximum number of suggestions we'll return for autocomplete
    [fetchRequest setFetchLimit:10];

    NSError* error = nil;
    NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(error)
        NSLog(@"Error during ReferencedEntity fetch: %@, %@", error, [error userInfo]);

    return results;
}

#pragma mark - Core Data Stack

- (NSManagedObjectContext*)managedObjectContext
{
    @synchronized(self)
    {
        if(_managedObjectContext)
            return _managedObjectContext;
        
        NSPersistentStoreCoordinator* coordinator = [self persistentStoreCoordinator];
        if(coordinator)
        {
            _managedObjectContext = [[NSManagedObjectContext alloc] init];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
            [_managedObjectContext setUndoManager:nil];
        }
        return _managedObjectContext;
    }
}

- (NSManagedObjectModel*)managedObjectModel
{
    @synchronized(self)
    {
        if(_managedObjectModel)
            return _managedObjectModel;
        NSURL* url = [[NSBundle mainBundle] URLForResource:@"AppAppModel" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
        return _managedObjectModel;
    }
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    @synchronized(self)
    {
        if(_persistentStoreCoordinator)
            return _persistentStoreCoordinator;

        NSURL* documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL* storeURL = [documentsURL URLByAppendingPathComponent:@"AppAppStore.sqlite"];
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"CoreData error, attempting automatic migration: %@, %@", error, [error userInfo]);

            // Attempt again with automatic lightweight migration
            NSDictionary* automaticMigrateDict = @{ NSMigratePersistentStoresAutomaticallyOption : @(YES), NSInferMappingModelAutomaticallyOption : @(YES) };

            if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:automaticMigrateDict error:&error]) {
                NSLog(@"CoreData error, deleting old store: %@, %@", error, [error userInfo]);

                // Remove existing store!
                [[NSFileManager defaultManager] removeItemAtURL:storeURL error:NULL];
                if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
                    NSLog(@"Unresolved CoreData error: %@, %@", error, [error userInfo]);
            }
        }    
        
        return _persistentStoreCoordinator;
    }
}

@end
