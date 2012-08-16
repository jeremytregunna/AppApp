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
    return @"Global Stream";
}

- (NSString *)sideMenuImageName
{
    return @"sidemenu_userstream_icon";
}


- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    
    if ([streamData count] > 0) {
        id firstPost = [streamData objectAtIndex:0];
        
        [[ANAPICall sharedAppAPI] getGlobalStreamSincePost:[firstPost objectForKey:@"id"] withCompletionBlock:^(id dataObject, NSError *error) {
            [self _updateTopWithData:dataObject];            
        }];
    } else {
        [[ANAPICall sharedAppAPI] getGlobalStream:^(id dataObject, NSError *error) {
            [self _updateTopWithData:dataObject];
        }];
    }
}

- (void)_updateTopWithData:(id)dataObject
{
    // begin updates on table
    [self.tableView beginUpdates];
    
    // get start indexpath
    NSUInteger startIndexPathRow = 0;
    NSUInteger endIndexPathRow = [dataObject count];
    
    // add data
    NSMutableIndexSet *indexSets = [NSMutableIndexSet indexSet];
    for (NSUInteger i = 0; i < [dataObject count]; i++) {
        [indexSets addIndex:i];
    }
    
    if (!streamData) {
        streamData = [NSMutableArray array];
    }
    
    [streamData insertObjects:dataObject atIndexes:indexSets];
    
    // initialize indexpaths
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:[dataObject count]];
    
    // create array of index paths
    while (startIndexPathRow < endIndexPathRow) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:startIndexPathRow inSection:0]];
        startIndexPathRow++;
    }
    
    // insert rows
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self refreshCompleted];
}

- (void)addItemsOnBottom
{
    // grab the last post
    id lastPost = [streamData lastObject];
    
    // if we have a post
    if (lastPost) {
        
        // fetch old data
        [[ANAPICall sharedAppAPI] getGlobalStreamBeforePost:[lastPost objectForKey:@"id"] withCompletionBlock:^(id dataObject, NSError *error) {

            // verify object
            if ([dataObject isKindOfClass:[NSArray class]])
            {
                // begin updates on table
                [self.tableView beginUpdates];

                // get start indexpath
                NSUInteger startIndexPathRow = [streamData count];
                NSUInteger endIndexPathRow = [dataObject count] + startIndexPathRow;
                
                // add data
                [streamData addObjectsFromArray:dataObject];
                
                // initialize indexpaths
                NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:[dataObject count]];
                
                // create array of index paths
                while (startIndexPathRow < endIndexPathRow) {
                    [indexPaths addObject:[NSIndexPath indexPathForRow:startIndexPathRow inSection:0]];
                    startIndexPathRow++;
                }

                // insert rows
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
                [self.tableView endUpdates];
            }
            
            [self loadMoreCompleted];
        }];        
    } else {
        [self loadMoreCompleted];
    }
}

@end
