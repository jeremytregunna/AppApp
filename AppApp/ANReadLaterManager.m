//
//  ANReadLaterManager.m
//  AppApp
//
//  Created by Jeremy Tregunna on 2012-08-22.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANReadLaterManager.h"
#import "PocketAPI.h"
#import "JSimpleInstapaper.h"

@implementation ANReadLaterManager
{
    NSMutableArray *failedSaveURLs;
}

@synthesize delegate = _delegate;

+ (NSString*)serviceNameForType:(ANReadLaterType)type
{
    switch(type)
    {
        case kANReadLaterTypePocket:
            return @"Pocket";
        case kANReadLaterTypeInstapaper:
            return @"Instapaper";
    }
}

#pragma mark - Object lifecycle

- (id)initWithDelegate:(id<ANReadLaterDelegate>)delegate
{
    if((self = [super init]))
    {
        failedSaveURLs = [NSMutableArray array];
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Saving URLs

- (void)saveURL:(NSURL *)url serviceType:(ANReadLaterType)type
{
    PocketAPISaveHandler handler = ^(id api, NSURL *savedURL, NSError *error, BOOL needsToRelogin) {
        if(error)
        {
            if([self.delegate respondsToSelector:@selector(readLater:serviceType:failedToSaveURL:needsToRelogin:error:)])
                [self.delegate readLater:self serviceType:type failedToSaveURL:savedURL needsToRelogin:needsToRelogin error:error];
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(readLater:serviceType:savedURL:)])
                [self.delegate readLater:self serviceType:type savedURL:savedURL];
        }
    };

    switch(type)
    {
        case kANReadLaterTypePocket:
        {
            [[PocketAPI sharedAPI] saveURL:url handler:handler];
            break;
        }
        case kANReadLaterTypeInstapaper:
        {
            [[JSimpleInstapaper sharedAPI] saveURL:url handler:(JSimpleInstapaperSaveHandler)handler];
            break;
        }
    }
}

@end
