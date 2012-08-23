//
//  JSimpleInstapaper.h
//  JSimpleInstapaper
//
//  Created by Jeremy Tregunna on 2012-08-23.
//  Copyright (c) 2012 Jeremy Tregunna. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JSimpleInstapaper;

typedef void(^JSimpleInstapaperLoginHandler)(JSimpleInstapaper* api, NSError* error);
typedef void(^JSimpleInstapaperSaveHandler)(JSimpleInstapaper* api, NSURL* url, NSError* error, BOOL needsToRelogin);

@interface JSimpleInstapaper : NSObject
@property (nonatomic, readonly, strong) NSString* username;
@property (nonatomic, readonly, strong) NSString* password;

+ (instancetype)sharedAPI;

- (void)loginWithUsername:(NSString*)username password:(NSString*)password handler:(JSimpleInstapaperLoginHandler)handler;
- (void)saveURL:(NSURL*)url handler:(JSimpleInstapaperSaveHandler)handler;

@end
