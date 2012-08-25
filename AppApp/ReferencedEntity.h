//
//  ReferencedEntity.h
//  AppApp
//
//  Created by Jeremy Tregunna on 2012-08-24.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum
{
    ANReferencedEntityTypeUsername,
    ANReferencedEntityTypeHashtag
} ANReferencedEntityType;

@interface ReferencedEntity : NSManagedObject
@property (nonatomic, retain) NSNumber* type;
@property (nonatomic, retain) NSString* name;
@end
