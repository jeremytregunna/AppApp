/*
 Copyright (c) 2012 T. Chroma, M. Herzog, N. Pannuto, J.Pittman, R. Rottmann, B. Sneed, V. Speelman
 The AppApp source code is distributed under the The MIT License (MIT) license.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.
 
 Any end-user product or application build based on this code, must include the following acknowledgment:
 
 "This product includes software developed by the original AppApp team and its contributors", in the software
 itself, including a link to www.app-app.net.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
*/

#import "ANAPICall.h"
#import "ANConstants.h"
#import "UIImage+SDExtensions.h"
#import "UIAlertView+SDExtensions.h"
#import "MKInfoPanel.h"
#import "NSDictionary+SDExtensions.h"
#import "AuthViewController.h"

@implementation ANAPICall
{
    id delegate;
    NSString *userID;
}

@synthesize accessToken;

+ (ANAPICall *)sharedAppAPI
{
    static dispatch_once_t oncePred;
    static ANAPICall *sharedInstance = nil;
    dispatch_once(&oncePred, ^{
        sharedInstance = [[[self class] alloc] initWithSpecification:@"ANAPI"];
    });
    return sharedInstance;
}

- (id)initWithSpecification:(NSString *)specificationName
{
    self = [super initWithSpecification:specificationName];
    
    // do some stuff here later.
    
    return self;
}

- (BOOL)hasAccessToken
{
    if (self.accessToken && self.userID)
        return YES;
    return NO;
}

- (NSString *)userID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *idValue = [defaults objectForKey:@"userID"];
    return idValue;
}

- (NSString *)accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *idValue = [defaults objectForKey:@"access_token"];
    if (!idValue)
        return @"";
    return idValue;
}

- (SDWebServiceDataCompletionBlock)defaultJSONProcessingBlock
{
    // refactor SDWebService so error's are passed around properly. -- BKS
    
    SDWebServiceDataCompletionBlock result = ^(int responseCode, NSString *response, NSError *error) {
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError = nil;
        id dataObject = nil;
        if (data)
            dataObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        return dataObject;
    };
    return result;
}

- (BOOL)handledError:(NSError *)error dataObject:(id)dataObject view:(UIView *)view
{
    BOOL result = FALSE;
    
    // error handling.  shmowzow!
    if (error)
        SDLog(@"error = %@", error);
    
    if (error.domain == SDWebServiceError || error.domain == NSURLErrorDomain)
    {
        [MKInfoPanel showPanelInView:view
                                type:MKInfoPanelTypeError
                               title:@"Network Error"
                            subtitle:@"Check your network connection.  App.net could also be down."
                           hideAfter:4];
        result = YES;
    }
    else
    if (dataObject)
    {
        NSDictionary *responseData = (NSDictionary *)responseData;
        NSUInteger code = [responseData unsignedIntegerForKeyPath:@"error.code"];
        if (code)
        {
            if (code == 401) // invalid access token
            {
                // got the unauthorized client code.  kill the access token and show the auth screen.
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:@"" forKey:@"access_token"];

                AuthViewController *authView = [[AuthViewController alloc] init];
                [view.window.rootViewController presentModalViewController:authView animated:YES];
            }
        }
    }
    
    return result;
}

- (void)makePostWithText:(NSString*)text uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    // App.net guys (? Alex K. and Mathew Phillips) say we should put accessToken in the headers, like so:
    // "Authorization: Bearer " + access_token
    
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"text" : text };
    [self performRequestWithMethod:@"postToStream" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)makePostWithText:(NSString*)text replyToPostID:(NSString *)postID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    // App.net guys (? Alex K. and Mathew Phillips) say we should put accessToken in the headers, like so:
    // "Authorization: Bearer " + access_token
    
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"text" : text, @"post_id" : postID };
    [self performRequestWithMethod:@"postToStreamAsReply" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];    
}

- (void)getGlobalStream:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken };
    [self performRequestWithMethod:@"getGlobalStream" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getGlobalStreamSincePost:(NSString*)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"since_id" : since_id };
    [self performRequestWithMethod:@"getGlobalStreamSince" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getGlobalStreamBeforePost:(NSString*)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"before_id" : before_id };
    [self performRequestWithMethod:@"getGlobalStreamBefore" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getTaggedPosts:(NSString*)hashtag withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"hashtag" : hashtag};
    [self performRequestWithMethod:@"getTaggedPosts" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getTaggedPosts:(NSString*)hashtag sincePost:(NSString*)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"since_id" : since_id, @"hashtag" : hashtag };
    [self performRequestWithMethod:@"getTaggedPostsSince" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getTaggedPosts:(NSString*)hashtag beforePost:(NSString*)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"before_id" : before_id, @"hashtag" : hashtag };
    [self performRequestWithMethod:@"getTaggedPostsBefore" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserStream:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken };
    [self performRequestWithMethod:@"getUserStream" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserStreamSincePost:(NSString*)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"since_id" : since_id };
    [self performRequestWithMethod:@"getUserStreamSince" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserStreamBeforePost:(NSString*)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"before_id" : before_id };
    [self performRequestWithMethod:@"getUserStreamBefore" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserPosts:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID };
    [self performRequestWithMethod:@"getUserPosts" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserPosts:(NSString *)ID SincePost:(NSString*)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID, @"since_id" : since_id };
    [self performRequestWithMethod:@"getUserPostsSince" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserPosts:(NSString *)ID BeforePost:(NSString*)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID, @"before_id" : before_id };
    [self performRequestWithMethod:@"getUserPostsBefore" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserPosts:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    [self getUserPosts:self.userID uiCompletionBlock:uiCompletionBlock];
}

- (void)getUserPostsSincePost:(NSString *)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    [self getUserPosts:self.userID SincePost:since_id withCompletionBlock:uiCompletionBlock];
}

- (void)getUserPostsBeforePost:(NSString *)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    [self getUserPosts:self.userID BeforePost:before_id withCompletionBlock:uiCompletionBlock];
}

- (void)getUserMentions:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID };
    [self performRequestWithMethod:@"getUserMentions" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserMentions:(NSString *)ID SincePost:(NSString*)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID, @"since_id" : since_id };
    [self performRequestWithMethod:@"getUserMentionsSince" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserMentions:(NSString *)ID BeforePost:(NSString*)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID, @"before_id" : before_id };
    [self performRequestWithMethod:@"getUserMentionsBefore" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserMentions:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    [self getUserMentions:self.userID uiCompletionBlock:uiCompletionBlock];
}

- (void)getUserMentionsSincePost:(NSString *)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    [self getUserMentions:self.userID SincePost:since_id withCompletionBlock:uiCompletionBlock];
}

- (void)getUserMentionsBeforePost:(NSString *)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    [self getUserMentions:self.userID BeforePost:before_id withCompletionBlock:uiCompletionBlock];
}

- (void)getCurrentUser:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken };
    [self performRequestWithMethod:@"getCurrentUser" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUser:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID };
    [self performRequestWithMethod:@"getUser" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserFollowers:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID };
    [self performRequestWithMethod:@"getUserFollowers" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getUserFollowing:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID };
    [self performRequestWithMethod:@"getUserFollowing" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getPostReplies:(NSString *)postID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"post_id" : postID };
    [self performRequestWithMethod:@"getPostReplies" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)followUser:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID };
    [self performRequestWithMethod:@"followUser" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)unfollowUser:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID };
    [self performRequestWithMethod:@"unfollowUser" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)muteUser:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID };
    [self performRequestWithMethod:@"muteUser" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)unmuteUser:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken, @"user_id" : ID };
    [self performRequestWithMethod:@"unmuteUser" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

- (void)getMutedUsers:(SDWebServiceUICompletionBlock)uiCompletionBlock
{
    NSDictionary *replacements = @{ @"accessToken" : self.accessToken};
    [self performRequestWithMethod:@"getMutedUsers" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
}

#pragma mark - Imgur upload

- (void)uploadImage:(UIImage *)image caption:(NSString *)caption uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
{
    // this one is speshul.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // should do a image resize here too.
        UIImage *resizedImage = [image resizedImageToFitInSize:CGSizeMake(320, 480) scaleIfSmaller:YES];
        NSString *imageData = [resizedImage base64forImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *replacements = @{ @"apiKey" : kImgurAPIKey, @"caption" : caption, @"base64image" : imageData };
            
            [self performRequestWithMethod:@"imgurPhotoUpload" routeReplacements:replacements dataProcessingBlock:[self defaultJSONProcessingBlock] uiUpdateBlock:uiCompletionBlock shouldRetry:NO];
        });
    });
}

@end
