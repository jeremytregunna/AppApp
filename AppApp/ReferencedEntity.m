//
//  ReferencedEntity.m
//  AppApp
//
//  Created by Jeremy Tregunna on 2012-08-24.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ReferencedEntity.h"
#import "ANDataStoreController.h"

@implementation ReferencedEntity
@dynamic type;
@dynamic name;

+ (ReferencedEntity*)referencedEntityWithType:(ANReferencedEntityType)type name:(NSString*)name
{
    ReferencedEntity* re;
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    NSManagedObjectContext* context = [[ANDataStoreController sharedController] managedObjectContext];
    
    request.entity = [NSEntityDescription entityForName:NSStringFromClass([self class])inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
    NSError* executeFetchError = nil;
    re = [[context executeFetchRequest:request error:&executeFetchError] lastObject];
    
    if(executeFetchError)
    {
        NSLog(@"Error looking up entity with name '%@' in %@ with error: %@", name, NSStringFromClass([self class]), [executeFetchError localizedDescription]);
    }
    else if(!re)
    {
        re = (ReferencedEntity*)[NSEntityDescription insertNewObjectForEntityForName:@"ReferencedEntity" inManagedObjectContext:[[ANDataStoreController sharedController] managedObjectContext]];
        re.type = @(type);
        re.name = name;
    }
    return re;
}

- (void)save:(NSError**)error successCallback:(void (^)())success
{
    if([[[ANDataStoreController sharedController] managedObjectContext] save:error] == YES)
        if(success) success();
}

@end
