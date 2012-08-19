//
//  ANAPICall.h
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebService.h"

@interface ANAPICall : SDWebService

@property (nonatomic, readonly) NSString *userID;

+ (ANAPICall *)sharedAppAPI;

/* access token methods. */

// check to answer whether we have a valid token for a session.
- (BOOL)hasAccessToken;

// validates whether the token is valid by requesting info about our user.
- (BOOL)isAccessTokenValid;


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

@end

@protocol ANAPIDelegate <NSObject>
// ...
@end