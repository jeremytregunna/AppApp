//
//  ANReadLaterManager.h
//  AppApp
//
//  Created by Jeremy Tregunna on 2012-08-22.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ANReadLaterManager;

typedef enum
{
    kANReadLaterTypePocket
} ANReadLaterType;

@protocol ANReadLaterDelegate <NSObject>
@optional
- (void)readLater:(ANReadLaterManager *)manager savedURL:(NSURL *)url;
- (void)readLater:(ANReadLaterManager *)manager failedToSaveURL:(NSURL *)url needsToRelogin:(BOOL)needsToRelogin error:(NSError *)error;
@end

@interface ANReadLaterManager : NSObject
@property (nonatomic, weak) id<ANReadLaterDelegate> delegate;

+ (NSString*)serviceNameForType:(ANReadLaterType)type;
- (id)initWithDelegate:(id<ANReadLaterDelegate>)delegate;
- (void)saveURL:(NSURL *)url serviceType:(ANReadLaterType)type;

@end
