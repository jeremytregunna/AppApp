//
//  JSimpleInstapaper.m
//  JSimpleInstapaper
//
//  Created by Jeremy Tregunna on 2012-08-23.
//  Copyright (c) 2012 Jeremy Tregunna. All rights reserved.
//

#import "JSimpleInstapaper.h"
#import "SFHFKeychainUtils.h"
#import "NSData+DTBase64.h"

static NSString* const JSimpleInstapaperServiceNameKey = @"JSimpleInstapaperServiceNameKey";
static NSString* const kJSimpleInstapaperAuthURLString = @"https://www.instapaper.com/api/authenticate";
static NSString* const kJSimpleInstapaperSaveURLString = @"https://www.instapaper.com/api/add";

@interface NSString (URLEncoding)
-(NSString*)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end

@implementation NSString (URLEncoding)
- (NSString*)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    return (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(encoding));
}
@end

@implementation JSimpleInstapaper
{
    NSOperationQueue* opQueue;
}

+ (instancetype)sharedAPI
{
    static id shared = nil;
    static dispatch_once_t instapaperToken;
    dispatch_once(&instapaperToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init
{
    if((self = [super init]))
    {
        opQueue = [NSOperationQueue mainQueue];
    }
    return self;
}

#pragma mark - Logging in

- (void)loginWithUsername:(NSString*)username password:(NSString*)password handler:(JSimpleInstapaperLoginHandler)handler
{
    NSURL* url = [NSURL URLWithString:kJSimpleInstapaperAuthURLString];
    NSURLRequest* request = [self requestForURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:opQueue completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        if(error == nil)
        {
            [self _setKeychainValue:username forKey:@"username"];
            [self _setKeychainValue:password forKey:@"password"];
        }

        if(handler != nil)
            handler(self, error);
    }];
}

#pragma mark - Saving URLs

- (void)saveURL:(NSURL*)url handler:(JSimpleInstapaperSaveHandler)handler
{
    NSString* encodedURL = [[url absoluteString] urlEncodeUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest* request = [self requestForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?url=%@", kJSimpleInstapaperSaveURLString, encodedURL]]];
    [NSURLConnection sendAsynchronousRequest:request queue:opQueue completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        BOOL needsToRelogin = NO;

        NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
        if(statusCode == 403)
        {
            error = [NSError errorWithDomain:@"JSimpleInstapaperDomain" code:400 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Invalid credentials. Try logging in again.", @"")}];
            needsToRelogin = YES;
        }
        else if(statusCode == 400)
        {
            error = [NSError errorWithDomain:@"JSimpleInstapaperDomain" code:400 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Malformed request. Please try again.", @"")}];
        }

        if(handler != nil)
            handler(self, url, error, needsToRelogin);
    }];
}

#pragma mark - Property getters

- (NSString*)username
{
    return [self _getKeychainValueForKey:@"username"];
}

- (NSString*)password
{
    return [self _getKeychainValueForKey:@"password"];
}

#pragma mark - Private helpers

- (NSURLRequest*)requestForURL:(NSURL*)url
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    NSString* authString = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
    NSData* authStringData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString* encodedAuthString = [authStringData base64EncodedString];
    [request setValue:[NSString stringWithFormat:@"Basic %@", encodedAuthString] forHTTPHeaderField:@"Authorization"];
    return [request copy];
}

- (void)_setKeychainValue:(id)value forKey:(NSString*)key
{
    if(value)
        [SFHFKeychainUtils storeUsername:key andPassword:value forServiceName:JSimpleInstapaperServiceNameKey updateExisting:YES error:nil];
    else
        [SFHFKeychainUtils deleteItemForUsername:key andServiceName:JSimpleInstapaperServiceNameKey error:nil];
}

- (NSString*)_getKeychainValueForKey:(NSString*)key
{
    return [SFHFKeychainUtils getPasswordForUsername:key andServiceName:JSimpleInstapaperServiceNameKey error:nil];
}

@end
