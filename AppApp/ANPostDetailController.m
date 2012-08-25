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

#import "ANPostDetailController.h"
#import "ANPostStatusViewController.h"
#import "ANPostDetailCell.h"
#import "ANAPICall.h"
#import "SDImageView.h"
#import "NSObject+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"
#import "UILabel+SDExtensions.h"

#import "ANUserViewController.h"

@interface ANPostDetailController ()

- (IBAction)userAction:(id)sender;

@end

@implementation ANPostDetailController
{
    NSDictionary *postData;
    NSInteger postIndex;
    id matchedObject;
    ANPostDetailCell *detailCell;
    CGFloat detailCellHeight;
}

- (id)initWithPostData:(NSDictionary *)aPostData
{
    self = [super init];
    
    postData = aPostData;
    postIndex = -1;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // we're gonna reuse this cell like two mofo's.
    
    detailCell = [ANPostDetailCell loadFromNib];
    detailCell.contentView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    detailCell.selectionStyle = UITableViewCellSelectionStyleNone;
    //detailCell.postLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    //detailCell.postLabel.delegate = self;
    detailCell.postLabel.postData = postData;
    detailCell.nameLabel.text = [postData stringForKeyPath:@"user.name"];
    detailCell.usernameLabel.text = [NSString stringWithFormat:@"@%@", [postData stringForKeyPath:@"user.username"]];
    detailCell.userImageView.imageURL = [postData stringForKeyPath:@"user.avatar_image.url"];
    //[detailCell.postLabel adjustHeightToFit:9999.0]; // hopefully unlimited in height...

    // now get that and set the header height..
    CGFloat defaultViewHeight = 221; // seen in the nib.
    CGFloat defaultLabelHeight = 21; // ... i'm putting these here in case we need to change it later.
    CGFloat newLabelHeight = detailCell.postLabel.frame.size.height;
    
    detailCellHeight = defaultViewHeight + (newLabelHeight - defaultLabelHeight);

    [detailCell.replyButton addTarget:self action:@selector(newPostAction:) forControlEvents:UIControlEventTouchUpInside];
    [detailCell.repostButton addTarget:self action:@selector(repostAction:) forControlEvents:UIControlEventTouchUpInside];
    [detailCell.userButton addTarget:self action:@selector(userAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    detailCell = nil;
}

#pragma mark - Button Actions

- (IBAction)newPostAction:(id)sender
{
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] initWithPostData:postData postMode:ANPostModeReply];
    [self presentModalViewController:postView animated:YES];
}

- (IBAction)repostAction:(id)sender
{
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] initWithPostData:postData postMode:ANPostModeRepost];
    [self presentModalViewController:postView animated:YES];
}

- (IBAction)userAction:(id)sender
{
    NSLog(@"here");
    NSDictionary *user = [postData objectForKey:@"user"];
    ANUserViewController *vc = [[ANUserViewController alloc] initWithUserDictionary:user];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 

- (NSString *)sideMenuTitle
{
    return @"Post";
}

- (NSInteger)indexOfTargetPost
{
    NSString *postID = [postData stringForKey:@"id"];
    postIndex = -1;
    for (NSInteger i = 0; i < [streamData count]; i++)
    {
        NSDictionary *postDict = [streamData objectAtIndex:i];
        NSString *thisID = [postDict stringForKey:@"id"];
        if ([thisID isEqualToString:postID])
        {
            postIndex = i;
            break;
        }
    }
    
    return postIndex;
}

#pragma mark - tableview overrides

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == postIndex)
        return;
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == postIndex)
        return detailCellHeight;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == postIndex)
        return detailCell;
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - refresh code

- (void)addItemsOnTop
{
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    
    // do nothing for now.  Replies isn't implemented by the API yet.
    
    NSString *postID = [postData stringForKey:@"id"];
    [[ANAPICall sharedAppAPI] getPostReplies:postID uiCompletionBlock:^(id dataObject, NSError *error) {
        if (![[ANAPICall sharedAppAPI] handledError:error dataObject:dataObject view:self.view])
        {
            // sort the array by postID, so everything is in order of occurrence.
            // surely all this could be done faster/better.  i challenge you to do it and it still work right.
            
            NSArray *sortedArray = [(NSArray *)dataObject sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *id1 = [obj1 stringForKey:@"id"];
                NSString *id2 = [obj2 stringForKey:@"id"];
                if ([id1 integerValue] > [id2 integerValue]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }
                
                if ([id1 integerValue] < [id2 integerValue]) {
                    return (NSComparisonResult)NSOrderedAscending;
                }
                
                return (NSComparisonResult)NSOrderedSame;
            }];
            
            streamData = [NSMutableArray arrayWithArray:sortedArray];
            
            postIndex = [self indexOfTargetPost];
            
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:postIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        [self refreshCompleted];
    }];
}

- (void)addItemsOnBottom
{
    //    [self.tableView reloadData];
    //
    //    if (items.count > 50)
    //        self.canLoadMore = NO; // signal that there won't be any more items to load
    //    else
    //        self.canLoadMore = YES;
    
    // Inform STableViewController that we have finished loading more items
    [self loadMoreCompleted];
}

/*- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}*/

@end
