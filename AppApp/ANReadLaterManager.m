//
//  ANReadLaterManager.m
//  AppApp
//
//  Created by Jeremy Tregunna on 2012-08-22.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANReadLaterManager.h"
#import "PocketAPI.h"

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
    switch(type)
    {
        case kANReadLaterTypePocket:
        {
            [[PocketAPI sharedAPI] saveURL:url handler:^(PocketAPI *api, NSURL *savedURL, NSError *error, BOOL needsToRelogin) {
                if(error)
                {
                    if([self.delegate respondsToSelector:@selector(readLater:failedToSaveURL:needsToRelogin:error:)])
                        [self.delegate readLater:self failedToSaveURL:savedURL needsToRelogin:needsToRelogin error:error];
                }
                else
                {
                    if([self.delegate respondsToSelector:@selector(readLater:savedURL:)])
                        [self.delegate readLater:self savedURL:savedURL];
                }
            }];
        }
    }
}

@end
