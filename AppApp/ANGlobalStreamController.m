//
//  ANGlobalStreamController.m
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANGlobalStreamController.h"

@implementation ANGlobalStreamController

- (NSString *)sideMenuTitle
{
    return @"Global";
}

- (NSString *)sideMenuImageName
{
    return @"sidemenu_globalstream_icon";
}


- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    
    // Check if already items in stream
    if ([streamData count] > 0) {
        // grab first post
        id firstPost = [streamData objectAtIndex:0];
        
        // get newest posts
        [[ANAPICall sharedAppAPI] getGlobalStreamSincePost:[firstPost objectForKey:@"id"] withCompletionBlock:^(id dataObject, NSError *error) {
            [self updateTopWithData:dataObject];
            [self refreshCompleted];
        }];
    } else {
        [[ANAPICall sharedAppAPI] getGlobalStream:^(id dataObject, NSError *error) {
            [self updateTopWithData:dataObject];
            [self refreshCompleted];            
        }];
    }
}

- (void)addItemsOnBottom
{
    // grab the last post
    id lastPost = [streamData lastObject];
    
    // if we have a post
    if (lastPost) {
        
        // fetch old data
        [[ANAPICall sharedAppAPI] getGlobalStreamBeforePost:[lastPost objectForKey:@"id"] withCompletionBlock:^(id dataObject, NSError *error) {
            [self updateBottomWithData:dataObject];
            [self loadMoreCompleted];
        }];        
    } else {
        [self loadMoreCompleted];
    }
}

@end
