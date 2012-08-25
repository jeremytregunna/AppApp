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

#import <QuartzCore/QuartzCore.h>
#import "ANBaseStreamController.h"
#import "ANPostStatusViewController.h"
#import "ANStreamFooterView.h"
#import "ANStreamHeaderView.h"
#import "ANUserViewController.h"
#import "ANPostDetailController.h"
#import "ANHashtagStreamController.h"

#import "MFSideMenu.h"
#import "NSObject+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"
//#import "NSDate+Helper.h"

#import "ANReadLaterManager.h"
#import "ANReadLaterAuthViewController.h"
#import "MKInfoPanel.h"
#import "TSMiniWebBrowser.h"


@interface ANBaseStreamController ()

@end

@implementation ANBaseStreamController
@synthesize currentToolbarView, btnConversation;

- (void)viewDidLoad
{
    self.title = self.sideMenuTitle;
    [super viewDidLoad];
    
    [self setupSideMenuBarButtonItem];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(newPostAction:)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                                     [[UIImage imageNamed:@"statusCellBackground"]
                                      resizableImageWithCapInsets:UIEdgeInsetsZero]];
    
    // setup refresh/load more
    
    self.headerView = [ANStreamHeaderView loadFromNib];
    self.footerView = [ANStreamFooterView loadFromNib];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.011 green:0.486 blue:0.682 alpha:1];
    
    // add gestures
    UISwipeGestureRecognizer *detailsRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToSideMenu:)];
    [detailsRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:detailsRecognizer];
    
    UISwipeGestureRecognizer *toolbarRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDetails:)];
    [toolbarRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:toolbarRecognizer];
    
    if ([[ANAPICall sharedAppAPI] hasAccessToken])
        [self refresh];
        
    if (!currentToolbarView) {
        self.currentToolbarView = [[UIView alloc] initWithFrame:CGRectZero];
        self.currentToolbarView.backgroundColor = [UIColor colorWithHue:0.574 saturation:0.036 brightness:0.984 alpha:1];
        
        UIImageView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Action_Bar_Separator.png"]];
        background.frame = CGRectMake(0,0,258,61);
        
        UIImage *btnReplyImg = [UIImage imageNamed:@"Action_Bar_Reply_Active.png"];
        UIButton *btnReply = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnReply addTarget:self action:@selector(replyToFromStream:) forControlEvents:UIControlEventTouchUpInside];
        [btnReply setImage:btnReplyImg forState:UIControlStateNormal];
        [btnReply setImage:btnReplyImg forState:UIControlStateHighlighted];
        [btnReply setFrame:CGRectMake(10,10,40,40)];
     
        UIImage *btnRepostImg = [UIImage imageNamed:@"Action_Bar_Repost_Active.png"];
        UIButton *btnRepost = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnRepost addTarget:self action:@selector(repostFromStream:) forControlEvents:UIControlEventTouchUpInside];
        [btnRepost setImage:btnRepostImg forState:UIControlStateNormal];
        [btnRepost setImage:btnRepostImg forState:UIControlStateHighlighted];
        
        [btnRepost setFrame:CGRectMake(60,10,40,40)];

        UIImage *btnConversationImg = [UIImage imageNamed:@"Action_Bar_Conversation_Active.png"];
        UIImage *btnConversationImgDisabled = [UIImage imageNamed:@"Action_Bar_Conversation_Disabled.png"];

        self.btnConversation = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btnConversation addTarget:self action:@selector(showConversation:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnConversation setImage:btnConversationImg forState:UIControlStateNormal];
        [self.btnConversation setImage:btnConversationImg forState:UIControlStateHighlighted];
        [self.btnConversation setImage:btnConversationImgDisabled forState:UIControlStateDisabled];
        [self.btnConversation setFrame:CGRectMake(110,10,40,40)];
        
        [self.currentToolbarView addSubview:background];
        [self.currentToolbarView addSubview:btnReply];
        [self.currentToolbarView addSubview:btnRepost];
        [self.currentToolbarView addSubview:self.btnConversation]; // self'ed because we need to be able to hide it on posts without replies (@ralf)
    }
    
    toolbarIsVisible = false;
    currentSelection = nil;
    newSelection = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    self.tableView.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Helper methods

- (void)composeStatus
{
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] init];
    [self presentModalViewController:postView animated:YES];
}

- (IBAction)newPostAction:(id)sender
{
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] init];
    [self presentModalViewController:postView animated:YES];
}

- (void)addOverlayToUserButton:(UIButton*)button
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = button.layer.bounds;
    gradientLayer.colors = @[ (id)[UIColor colorWithWhite:0.3f alpha:0.4f].CGColor, (id)[UIColor colorWithWhite:0.0f alpha:0.4f].CGColor ];
    gradientLayer.locations = @[ @0, @0.5 ];
    gradientLayer.name = @"overlayGradient";
    [button.layer addSublayer:gradientLayer];
}

- (void)removeLayerFromView:(UIView*)view
{
    CAGradientLayer *gradientLayer = [[view.layer.sublayers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", @"overlayGradient"]] objectAtIndex:0];
    [gradientLayer removeFromSuperlayer];
}

- (void)showUserAction:(id)sender
{
    UIControl *control = (UIControl *)sender;
    [self removeLayerFromView:control];
    NSUInteger index = [control tag];
    NSDictionary *postDict = [streamData objectAtIndex:index];
    NSDictionary *userDict = [postDict objectForKey:@"user"];
    ANUserViewController *userController = [[ANUserViewController alloc] initWithUserDictionary:userDict];
    [self.navigationController pushViewController:userController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [streamData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDictionary *postData = [streamData objectAtIndex:[indexPath row]];
    ANPostLabel *tempLabel = [[ANPostLabel alloc] initWithFrame:CGRectZero];
    tempLabel.postData = postData;
    
    CGSize statusLabelSize = [tempLabel suggestedFrameSizeToFitEntireStringConstraintedToWidth:230];
    
    CGFloat height = MAX(ANStatusViewCellUsernameTextHeight + statusLabelSize.height, ANStatusViewCellAvatarHeight)
            + ANStatusViewCellTopMargin + ANStatusViewCellBottomMargin;
    
    if ((currentSelection) && (currentSelection.row == indexPath.row))
    {
        height += 61;
    }

    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ANStatusViewCell";
    ANStatusViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ANStatusViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.statusTextLabel.tapHandler = ^BOOL (NSString *type, NSString *value) {
            BOOL result = NO;
            if ([type isEqualToString:@"hashtag"])
            {
                NSString *hashtag = value;
                ANHashtagStreamController *hashtagController = [[ANHashtagStreamController alloc] initWithHashtag:hashtag];
                [self.navigationController pushViewController:hashtagController animated:YES];
            }
            else
            if ([type isEqualToString:@"name"])
            {
                NSString *userID = value;
                [[ANAPICall sharedAppAPI] getUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
                    if (![[ANAPICall sharedAppAPI] handledError:error dataObject:dataObject view:self.view])
                    {
                        NSDictionary *userData = dataObject;
                        ANUserViewController* userViewController = [[ANUserViewController alloc] initWithUserDictionary:userData];
                        [self.navigationController pushViewController:userViewController animated:YES];
                    }
                }];
            }
            else
            if ([type isEqualToString:@"link"])
            {
                /*NSURL *url = [NSURL URLWithString:value];
                if ([[UIApplication sharedApplication] canOpenURL:url])
                    [[UIApplication sharedApplication] openURL:url];*/
                TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:@"http://indiedevstories.com"]];
                //    webBrowser.delegate = self;
                //    webBrowser.showURLStringOnActionSheetTitle = YES;
                //    webBrowser.showPageTitleOnTitleBar = YES;
                    webBrowser.showActionButton = YES;
                    webBrowser.showReloadButton = YES;
                //    [webBrowser setFixedTitleBarText:@"Test Title Text"]; // This has priority over "showPageTitleOnTitleBar".
                webBrowser.mode = TSMiniWebBrowserModeNavigation;
                
                //webBrowser.barStyle = UIBarStyleBlack;
                
                if (webBrowser.mode == TSMiniWebBrowserModeModal)
                {
                    webBrowser.modalDismissButtonTitle = @"Home";
                    [self presentModalViewController:webBrowser animated:YES];
                }
                else
                if(webBrowser.mode == TSMiniWebBrowserModeNavigation)
                {
                    [self.navigationController pushViewController:webBrowser animated:YES];
                }

            }
            return result;
        };
        
        __weak typeof(self) blockSelf = self;
        cell.statusTextLabel.longPressHandler = ^BOOL (NSString *type, NSString *value) {
            if([type isEqualToString:@"link"])
            {
                UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:value delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Send to Pocket", @""), NSLocalizedString(@"Send to Instapaper", @""), nil];
                [sheet showInView:blockSelf.view];
            }
            else
            {
                // TODO: Craft a URL pointing to the post on alpha.app.net
                //       open the action sheet above with this URL. @jtregunna
            }
            return YES;
        };
    }

    NSDictionary *statusDict = [streamData objectAtIndex:[indexPath row]];
    
    cell.postData = statusDict;

    // TODO: i know this is janky.  fix it.
    cell.showUserButton.tag = indexPath.row;
    // END JANKY.

    [cell.showUserButton addTarget:self action:@selector(addOverlayToUserButton:) forControlEvents:UIControlEventTouchDown];
    [cell.showUserButton addTarget:self action:@selector(removeLayerFromView:) forControlEvents:UIControlEventTouchDragOutside];
    [cell.showUserButton addTarget:self action:@selector(showUserAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleToolbarAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (toolbarIsVisible) {
        [self.currentToolbarView removeFromSuperview];
        toolbarIsVisible = false;
        currentSelection = nil;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    [super scrollViewDidScroll:scrollView];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ANReadLaterManager *manager = [[ANReadLaterManager alloc] initWithDelegate:self];

    switch(buttonIndex)
    {
        case 0: // Pocket
            [manager saveURL:[NSURL URLWithString:actionSheet.title] serviceType:kANReadLaterTypePocket];
            break;
        case 1:
            [manager saveURL:[NSURL URLWithString:actionSheet.title] serviceType:kANReadLaterTypeInstapaper];
            break;
    }
}

#pragma mark - Read Later delegate

- (void)readLater:(ANReadLaterManager *)manager serviceType:(ANReadLaterType)serviceType didLoginSuccessfullyWithURL:(NSURL *)url
{
    [manager saveURL:url serviceType:serviceType];
}

- (void)readLater:(ANReadLaterManager *)manager serviceType:(ANReadLaterType)serviceType savedURL:(NSURL *)url
{
    NSString* message = [NSString stringWithFormat:@"Successfully saved URL to %@", [ANReadLaterManager serviceNameForType:serviceType]];
    [MKInfoPanel showPanelInView:self.view type:MKInfoPanelTypeInfo title:NSLocalizedString(@"Saved URL", @"") subtitle:NSLocalizedString(message, @"") hideAfter:2.5f];
}

- (void)readLater:(ANReadLaterManager *)manager serviceType:(ANReadLaterType)serviceType failedToSaveURL:(NSURL *)url needsToRelogin:(BOOL)needsToRelogin error:(NSError *)error
{
    if(needsToRelogin)
    {
        ANReadLaterAuthViewController* vc = [[ANReadLaterAuthViewController alloc] initWithServiceType:serviceType failedURL:url manager:manager];
        [self presentModalViewController:vc animated:YES];
    }
    else
    {
        [MKInfoPanel showPanelInView:self.view type:MKInfoPanelTypeError title:NSLocalizedString(@"Error Saving URL", @"") subtitle:[error localizedDescription] hideAfter:2.5f];
    }
}

#pragma mark - Gesture Handling

- (void)swipeToDetails:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    
    NSDictionary *postData = [streamData objectAtIndex:indexPath.row];
    ANPostDetailController *detailController = [[ANPostDetailController alloc] initWithPostData:postData];
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)swipeToToolbar:(UISwipeGestureRecognizer *)gestureRecognizer
{
    
    CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    ANStatusViewCell *currentCell = (ANStatusViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    newSelection = indexPath;
    
    if ((currentSelection) && (newSelection.row == currentSelection.row)) { // user swiped on same cell twice
        if (!toolbarIsVisible) {
            [self.currentToolbarView setFrame:CGRectMake(71, currentCell.frame.size.height, 260, 47)];
            self.currentToolbarView.tag = indexPath.row;
            NSLog(@"Tag: %i",  self.currentToolbarView.tag);
            [self toggleToolbarButtonsForIndexPath:indexPath];
            [currentCell addSubview:self.currentToolbarView];
            toolbarIsVisible = true;
            currentSelection = indexPath;
        } else {
            [self hideToolbar];
        }
    } else { // user swiped on new cell
        [self.currentToolbarView setFrame:CGRectMake(71, currentCell.frame.size.height, 260, 47)];
        self.currentToolbarView.tag = indexPath.row;
        [self toggleToolbarButtonsForIndexPath:indexPath];
        [currentCell addSubview:self.currentToolbarView];
        toolbarIsVisible = true;
        currentSelection = indexPath;
    }
        
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (void)toggleToolbarAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];

    ANStatusViewCell *currentCell = (ANStatusViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];    
    newSelection = indexPath;
    
    if ((currentSelection) && (newSelection.row == currentSelection.row)) { // user swiped on same cell twice
        if (!toolbarIsVisible) {
            [self.currentToolbarView setFrame:CGRectMake(71, currentCell.frame.size.height, 260, 47)];
            self.currentToolbarView.tag = indexPath.row;
            NSLog(@"Tag: %i",  self.currentToolbarView.tag);
            [self toggleToolbarButtonsForIndexPath:indexPath];
            [currentCell addSubview:self.currentToolbarView];
            toolbarIsVisible = true;
            currentSelection = indexPath;
        } else {
            [self hideToolbar];
        }
    } else { // user swiped on new cell
        [self.currentToolbarView setFrame:CGRectMake(71, currentCell.frame.size.height, 260, 47)];
        self.currentToolbarView.tag = indexPath.row;
        [self toggleToolbarButtonsForIndexPath:indexPath];
        [currentCell addSubview:self.currentToolbarView];

        toolbarIsVisible = true;
        currentSelection = indexPath;
    }
    
    [self.tableView endUpdates];
    
}

- (void)hideToolbar
{
    [self.currentToolbarView removeFromSuperview];
    toolbarIsVisible = false;
    currentSelection = nil;
}

- (void)toggleToolbarButtonsForIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *postData = [streamData objectAtIndex:indexPath.row];
    NSString *numReplies = [postData stringForKeyPath:@"num_replies"];
    NSString *isReplyTo = [postData stringForKeyPath:@"reply_to"];
    if (([numReplies isEqualToString:@"0"]) && (!isReplyTo))
    {
        self.btnConversation.enabled = NO;
    } else
    {
        self.btnConversation.enabled = YES;
    }
}

- (void)swipeToSideMenu:(UISwipeGestureRecognizer *)gestureRecognizer
{
    //CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
    //NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    
    [self.navigationController setMenuState:MFSideMenuStateVisible];
}

#pragma mark - Pull to Refresh

- (void) pinHeaderView
{
    [super pinHeaderView];
    
    // do custom handling for the header view
    ANStreamHeaderView *hv = (ANStreamHeaderView *)self.headerView;
    [hv.activityIndicator startAnimating];
    hv.title.text = @"Loading...";
}

- (void) unpinHeaderView
{
    [super unpinHeaderView];
    
    // do custom handling for the header view
    [[(ANStreamHeaderView *)self.headerView activityIndicator] stopAnimating];
}

// Update the header text while the user is dragging
- (void) headerViewDidScroll:(BOOL)willRefreshOnRelease scrollView:(UIScrollView *)scrollView
{
    ANStreamHeaderView *hv = (ANStreamHeaderView *)self.headerView;
    if (willRefreshOnRelease)
        hv.title.text = @"Release to refresh...";
    else
        hv.title.text = @"Pull down to refresh...";
}

- (BOOL)refresh
{
    if (![super refresh])
        return NO;
    
    // Do your async call here
    // This is just a dummy data loader:
    [self performSelector:@selector(addItemsOnTop) withObject:nil afterDelay:2.0];
    // See -addItemsOnTop for more info on how to finish loading
    return YES;
}

#pragma mark - Load More

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// The method -loadMore was called and will begin fetching data for the next page (more).
// Do custom handling of -footerView if you need to.
//
- (void) willBeginLoadingMore
{
    ANStreamFooterView *fv = (ANStreamFooterView *)self.footerView;
    [fv.activityIndicator startAnimating];
}

// Do UI handling after the "load more" process was completed. In this example, -footerView will
// show a "No more items to load" text.
- (void) loadMoreCompleted
{
    [super loadMoreCompleted];
    
    ANStreamFooterView *fv = (ANStreamFooterView *)self.footerView;
    [fv.activityIndicator stopAnimating];
    
    if (!self.canLoadMore) {
        // Do something if there are no more items to load
        
        // We can hide the footerView by: [self setFooterViewVisibility:NO];
        
        // Just show a textual info that there are no more items to load
        fv.infoLabel.hidden = NO;
    }
}

- (BOOL) loadMore
{
    if (![super loadMore])
        return NO;
    
    // Do your async loading here
    [self performSelector:@selector(addItemsOnBottom) withObject:nil afterDelay:2.0];
    // See -addItemsOnBottom for more info on what to do after loading more items
    
    return YES;
}

#pragma mark - Refresh methods

- (void)addItemsOnTop
{
//    [self.tableView reloadData];
    
    // Call this to indicate that we have finished "refreshing".
    // This will then result in the headerView being unpinned (-unpinHeaderView will be called).
    /*[[ANAPICall sharedAppAPI] getGlobalStream:^(id dataObject, NSError *error) {
        streamData = [NSMutableArray arrayWithArray:dataObject];
        [self.tableView reloadData];
        [self refreshCompleted];
    }];*/
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
    //[self loadMoreCompleted];
}

#pragma mark -
#pragma mark Data/UI Updates
// Will update top of table, and data from data object
- (void)updateTopWithData:(id)dataObject
{
    // verify object
    if ([dataObject isKindOfClass:[NSArray class]])
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
    }
}

- (void)updateBottomWithData:(id)dataObject
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

#pragma mark -
#pragma mark Action Bar methods
- (void)replyToFromStream:(id)sender {
    NSDictionary *postData = [streamData objectAtIndex:[[(UIButton *)sender superview] tag]];
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] initWithPostData:postData postMode:ANPostModeReply];
    [self presentModalViewController:postView animated:YES];
}

- (void)repostFromStream:(id)sender {
    NSDictionary *postData = [streamData objectAtIndex:[[(UIButton *)sender superview] tag]];
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] initWithPostData:postData postMode:ANPostModeRepost];
    [self presentModalViewController:postView animated:YES];
}

- (void)showConversation:(id)sender {
    NSDictionary *postData = [streamData objectAtIndex:[[(UIButton *)sender superview] tag]];
    ANPostDetailController *detailController = [[ANPostDetailController alloc] initWithPostData:postData];
    [self.navigationController pushViewController:detailController animated:YES];
}

@end
