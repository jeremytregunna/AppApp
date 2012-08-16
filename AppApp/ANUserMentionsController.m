//
//  ANUserMentionsController.m
//  AppApp
//
//  Created by Nick Pannuto on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANUserMentionsController.h"

@interface ANUserMentionsController ()

@end

@implementation ANUserMentionsController

- (NSString *)sideMenuTitle
{
    return @"User Mentions";
}

- (NSString *)sideMenuImageName
{
    return @"sidemenu_usermentions_icon";
}

- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    [[ANAPICall sharedAppAPI] getUserMentions:^(id dataObject, NSError *error) {
        [self updateTopWithData:dataObject];
        [self refreshCompleted];
    }];
}

- (void)addItemsOnBottom
{
    // grab the last post
    id lastPost = [streamData lastObject];
    
    // if we have a post
    if (lastPost) {
        
        // fetch old data
        [[ANAPICall sharedAppAPI] getUserMentionsBeforePost:[lastPost objectForKey:@"id"] withCompletionBlock:^(id dataObject, NSError *error) {
            [self updateBottomWithData:dataObject];
            [self loadMoreCompleted];
        }];
    } else {
        [self loadMoreCompleted];
    }
}

@end
