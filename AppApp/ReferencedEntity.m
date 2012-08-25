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
    ReferencedEntity* re = (ReferencedEntity*)[NSEntityDescription insertNewObjectForEntityForName:@"ReferencedEntity" inManagedObjectContext:[[ANDataStoreController sharedController] managedObjectContext]];
    re.type = @(type);
    re.name = name;
    return re;
}

- (void)save:(NSError**)error successCallback:(void (^)())success
{
    if([[[ANDataStoreController sharedController] managedObjectContext] save:error] == YES)
        if(success) success();
}

@end
