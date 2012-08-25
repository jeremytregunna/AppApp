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

#import <Foundation/Foundation.h>
#import "SDWebService.h"

@interface ANAPICall : SDWebService

@property (nonatomic, readonly) NSString *userID;
@property (nonatomic, readonly) NSString *accessToken;

+ (ANAPICall *)sharedAppAPI;

/* access token methods. */

// check to answer whether we have a valid token for a session.
- (BOOL)hasAccessToken;

// ui completion blocks call this, handle more global errors.
- (BOOL)handledError:(NSError *)error dataObject:(id)dataObject view:(UIView *)view;

- (void)makePostWithText:(NSString*)text uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)makePostWithText:(NSString*)text replyToPostID:(NSString *)postID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;

- (void)getGlobalStream:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getGlobalStreamSincePost:(NSString*)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getGlobalStreamBeforePost:(NSString*)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getTaggedPosts:(NSString*)hashtag withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getTaggedPosts:(NSString*)hashtag sincePost:(NSString*)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getTaggedPosts:(NSString*)hashtag beforePost:(NSString*)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserStream:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserStreamSincePost:(NSString*)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserStreamBeforePost:(NSString*)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserPosts:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserPostsSincePost:(NSString *)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserPostsBeforePost:(NSString *)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserPosts:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserPosts:(NSString *)ID SincePost:(NSString*)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserPosts:(NSString *)ID BeforePost:(NSString*)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserMentions:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserMentionsSincePost:(NSString *)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserMentionsBeforePost:(NSString *)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserMentions:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserMentions:(NSString *)ID SincePost:(NSString*)since_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserMentions:(NSString *)ID BeforePost:(NSString*)before_id withCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getCurrentUser:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUser:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserFollowers:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getUserFollowing:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getPostReplies:(NSString *)postID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;

- (void)followUser:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)unfollowUser:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)muteUser:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)unmuteUser:(NSString *)ID uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;
- (void)getMutedUsers:(SDWebServiceUICompletionBlock)uiCompletionBlock;

// this is weird yes.  its an imgur api, but its key.  SDWebService doesn't support multiple service plists :(
- (void)uploadImage:(UIImage *)image caption:(NSString *)caption uiCompletionBlock:(SDWebServiceUICompletionBlock)uiCompletionBlock;

- (NSString *)userID;
- (NSString *)accessToken;

@end

@protocol ANAPIDelegate <NSObject>
// ...
@end