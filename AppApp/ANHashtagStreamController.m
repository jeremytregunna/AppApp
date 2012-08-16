//
//  ANHashtagStreamController.m
//  AppApp
//
//  Created by brandon on 8/16/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANHashtagStreamController.h"

@interface ANHashtagStreamController ()

@end

@implementation ANHashtagStreamController
{
    NSString *hashtag;
}

- (id)initWithHashtag:(NSString *)aHashtag
{
    self = [super init];
    
    hashtag = aHashtag;
    
    return self;
}


- (NSString *)sideMenuTitle
{
    return [NSString stringWithFormat:@"#%@", hashtag];
}

/*- (NSString *)sideMenuImageName
{
    return @"sidemenu_userstream_icon";
}*/

- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    
    if ([streamData count] > 0) {
        id firstPost = [streamData objectAtIndex:0];
        [[ANAPICall sharedAppAPI] getTaggedPosts:hashtag sincePost:[firstPost objectForKey:@"id"] withCompletionBlock:^(id dataObject, NSError *error) {
            [self updateTopWithData:dataObject];
            [self refreshCompleted];
        }];
    } else {
        [[ANAPICall sharedAppAPI] getTaggedPosts:hashtag withCompletionBlock:^(id dataObject, NSError *error) {
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
        [[ANAPICall sharedAppAPI] getTaggedPosts:hashtag beforePost:[lastPost objectForKey:@"id"] withCompletionBlock:^(id dataObject, NSError *error) {
            [self updateBottomWithData:dataObject];
            [self loadMoreCompleted];
        }];
    } else {
        [self loadMoreCompleted];
    }
}

@end
