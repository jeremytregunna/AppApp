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

#import "ANUserPostsController.h"

@interface ANUserPostsController ()

@end

@implementation ANUserPostsController
{
    NSString *userID;
}

- (id)init
{
    self = [super init];
    return self;
}

- (id)initWithUserID:(NSString *)aUserID
{
    self = [super init];
    
    userID = aUserID;
    
    return self;
}

- (NSString *)sideMenuTitle
{
    return @"Posts";
}


- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    
    if (userID)
    {
        [[ANAPICall sharedAppAPI] getUserPosts:userID uiCompletionBlock:^(id dataObject, NSError *error) {
            if (![[ANAPICall sharedAppAPI] handledError:error dataObject:dataObject view:self.view])
            {
                streamData = [NSMutableArray arrayWithArray:dataObject];
                [self.tableView reloadData];
            }
            [self refreshCompleted];
        }];
    }
    else
    {
        [[ANAPICall sharedAppAPI] getUserPosts:^(id dataObject, NSError *error) {
            if (![[ANAPICall sharedAppAPI] handledError:error dataObject:dataObject view:self.view])
            {
                streamData = [NSMutableArray arrayWithArray:dataObject];
                [self.tableView reloadData];
            }
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
        
        if (userID)
        {
            // fetch old data
            [[ANAPICall sharedAppAPI] getUserPosts:userID BeforePost:[lastPost objectForKey:@"id"] withCompletionBlock:^(id dataObject, NSError *error) {
                if (![[ANAPICall sharedAppAPI] handledError:error dataObject:dataObject view:self.view])
                {
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
                }
                [self loadMoreCompleted];
            }];

        }
        else
        {
            // fetch old data
            [[ANAPICall sharedAppAPI] getUserPostsBeforePost:[lastPost objectForKey:@"id"] withCompletionBlock:^(id dataObject, NSError *error) {
                if (![[ANAPICall sharedAppAPI] handledError:error dataObject:dataObject view:self.view])
                {
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
                }
                [self loadMoreCompleted];
            }];
        }
    } else {
        [self loadMoreCompleted];
    }
}

@end
