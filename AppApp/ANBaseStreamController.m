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

#import "SVProgressHUD.h"


@interface ANBaseStreamController () {
    BOOL _hasFirstLoadOccurred;
}

@end

@implementation ANBaseStreamController
{
    NSInteger actionBarRow;
}

- (void)viewDidLoad
{
    self.title = self.sideMenuTitle;
    [super viewDidLoad];
    
    actionBarRow = -1;
    
    [self setupSideMenuBarButtonItem];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                           target:self
                                                                                           action:@selector(newPostAction:)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // this stuff kills drawing performance.
    self.tableView.backgroundColor = [UIColor colorWithRed:1/255.0f green:76/255.0f blue:106/255.0f alpha:1.0f];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                                     [[UIImage imageNamed:@"statusCellBackground"]
                                      resizableImageWithCapInsets:UIEdgeInsetsZero]];
    
    // setup refresh/load more
    self.headerView = [ANStreamHeaderView loadFromNib];
    self.footerView = [ANStreamFooterView loadFromNib];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.011 green:0.486 blue:0.682 alpha:1];
    
    // iOS 5 and up, should make tableViews more buttery (thanks @mattyohe)
        NSString *myIdentifier = @"ANStatusViewCell";
    [self.tableView registerNib:[UINib nibWithNibName:@"ANStatusCell" bundle:nil]
                  forCellReuseIdentifier:myIdentifier];
    
    // add gestures
    UISwipeGestureRecognizer *detailsRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToSideMenu:)];
    [detailsRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.tableView addGestureRecognizer:detailsRecognizer];
    
    UISwipeGestureRecognizer *toolbarRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDetails:)];
    [toolbarRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [self.tableView addGestureRecognizer:toolbarRecognizer];
    
    if ([[ANAPICall sharedAppAPI] hasAccessToken])
        [self refresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applyChangedSettings:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    if (self.navigationController.visibleViewController != self)
        self.view = nil;
}

- (void)applyChangedSettings:(NSNotification *)notification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
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

- (void)showUserAction:(id)sender
{
    UIControl *control = (UIControl *)sender;
    NSUInteger index = control.tag;
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
    tempLabel.enableDataDetectors = NO;
    tempLabel.enableLinks = NO;
    tempLabel.postText = [postData stringForKey:@"text"];
    
    CGSize statusLabelSize = [tempLabel sizeThatFits:CGSizeMake(230, 10000)];
    
    CGFloat labelHeight = MAX(statusLabelSize.height, [ANStatusCell baseTextHeight]);
    CGFloat cellHeight = ([ANStatusCell baseHeight:(actionBarRow == indexPath.row)] - [ANStatusCell baseTextHeight]) + labelHeight;

    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ANStatusViewCell";
    ANStatusCell *cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [ANStatusCell loadFromNib];
        [cell prepareForReuse];
        
        // this only needs to be done once, otherwise actions will keep piling up since we never remove them.
        // also, since we use an index, they're straight up legit pa'nuh.
        [cell.replyButton addTarget:self action:@selector(replyToFromStream:) forControlEvents:UIControlEventTouchUpInside];
        [cell.repostButton addTarget:self action:@selector(repostFromStream:) forControlEvents:UIControlEventTouchUpInside];
        [cell.convoButton addTarget:self action:@selector(showConversation:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.showUserButton addTarget:self action:@selector(showUserAction:) forControlEvents:UIControlEventTouchUpInside];

        __weak typeof(self) blockSelf = self;

        cell.statusTextLabel.tapHandler = ^BOOL (NSURL *url) {
            BOOL result = NO;
            if ([url.scheme isEqualToString:@"adnhashtag"])
            {
                NSString *hashtag = [[url absoluteString] stringByReplacingOccurrencesOfString:@"adnhashtag://#" withString:@""];
                ANHashtagStreamController *hashtagController = [[ANHashtagStreamController alloc] initWithHashtag:hashtag];
                [blockSelf.navigationController pushViewController:hashtagController animated:YES];
            }
            else
            if ([url.scheme isEqualToString:@"adnuser"] && ![SVProgressHUD isVisible])
            {
                NSString *userID = [[url absoluteString] stringByReplacingOccurrencesOfString:@"adnuser://" withString:@""];;
                [SVProgressHUD showWithStatus:@"Fetching user..." maskType:SVProgressHUDMaskTypeBlack];
                [[ANAPICall sharedAppAPI] getUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
                    if (![[ANAPICall sharedAppAPI] handledError:error dataObject:dataObject view:blockSelf.view])
                    {
                        NSDictionary *userData = dataObject;
                        ANUserViewController* userViewController = [[ANUserViewController alloc] initWithUserDictionary:userData];
                        [blockSelf.navigationController pushViewController:userViewController animated:YES];
                        [SVProgressHUD dismiss];
                    }
                }];
            }
            else
            {
                NSString *urlString = [url absoluteString];
                NSURL *newURL = url;
                
                // make sure we pick up any changes.
                [[NSUserDefaults standardUserDefaults] synchronize];
                BOOL useSafari = [[[NSUserDefaults standardUserDefaults] objectForKey:@"prefUseSafari"] boolValue];
                BOOL useChrome = [[[NSUserDefaults standardUserDefaults] objectForKey:@"prefUseChrome"] boolValue];
                
                if (useChrome)
                {
                    NSString *chromeString = [urlString stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@"googlechrome"];
                    newURL = [NSURL URLWithString:chromeString];
                }
                
                BOOL canOpenURL = [[UIApplication sharedApplication] canOpenURL:newURL];
                
                if ((useSafari || useChrome) && canOpenURL)
                {
                    [[UIApplication sharedApplication] openURL:newURL];
                }
                else
                {
                    TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:url];
                    webBrowser.showActionButton = YES;
                    webBrowser.showReloadButton = YES;
                    webBrowser.mode = TSMiniWebBrowserModeNavigation;
                
                    if (webBrowser.mode == TSMiniWebBrowserModeModal)
                    {
                        webBrowser.modalDismissButtonTitle = @"Home";
                        [blockSelf presentModalViewController:webBrowser animated:YES];
                    }
                    else
                    if(webBrowser.mode == TSMiniWebBrowserModeNavigation)
                    {
                        [blockSelf.navigationController pushViewController:webBrowser animated:YES];
                    }
                }
            }
            return result;
        };
        
        cell.statusTextLabel.longPressHandler = ^BOOL (NSURL *url) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            if([url.scheme isEqualToString:@"http"])
            {
                NSString *serviceName = [defaults objectForKey:@"prefReadLater"];
                if(serviceName && [serviceName isEqualToString:@""] == NO)
                {
                    ANReadLaterManager *manager = [[ANReadLaterManager alloc] initWithDelegate:self];
                    ANReadLaterType readLaterService = NSNotFound;
                    if([serviceName isEqualToString:@"Pocket"])
                        readLaterService = kANReadLaterTypePocket;
                    else if([serviceName isEqualToString:@"Instapaper"])
                        readLaterService = kANReadLaterTypeInstapaper;
                    [manager saveURL:url serviceType:readLaterService];
                }
                else
                {
                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:blockSelf cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Send to Pocket", @""), NSLocalizedString(@"Send to Instapaper", @""), nil];
                    [sheet showInView:blockSelf.view];
                }
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
    
    if (actionBarRow == indexPath.row)
        cell.showActionBar = YES;
    else
        cell.showActionBar = NO;

    // TODO: i know this is janky.  fix it.
    cell.showUserButton.tag = indexPath.row;
    // END JANKY.

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *rowsToReload = [NSMutableArray arrayWithCapacity:2];
    if (actionBarRow > -1)
    {
        NSIndexPath *oldRow = [NSIndexPath indexPathForRow:actionBarRow inSection:0];
        [rowsToReload addObject:oldRow];
    }
    ANStatusCell *cell = (ANStatusCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.showActionBar)
        actionBarRow = -1;
    else
    {
        actionBarRow = indexPath.row;
        [rowsToReload addObject:indexPath];
    }
    [tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationFade];
    
    //ANHashtagStreamController *hashtagController = [[ANHashtagStreamController alloc] initWithHashtag:@"appapp"];
    //[self.navigationController pushViewController:hashtagController animated:YES];

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (actionBarRow != -1)
    {
        NSIndexPath *oldRow = [NSIndexPath indexPathForRow:actionBarRow inSection:0];
        actionBarRow = -1;
        [self.tableView reloadRowsAtIndexPaths:@[oldRow] withRowAnimation:UITableViewRowAnimationNone];
    }

    [super scrollViewDidScroll:scrollView];
}

#pragma mark - Action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    ANReadLaterManager *manager = [[ANReadLaterManager alloc] initWithDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    switch(buttonIndex)
    {
        case 0: // Pocket
            [manager saveURL:[NSURL URLWithString:actionSheet.title] serviceType:kANReadLaterTypePocket];
            [defaults setObject:@"Pocket" forKey:@"prefReadLater"];
            [defaults synchronize];
            break;
        case 1:
            [manager saveURL:[NSURL URLWithString:actionSheet.title] serviceType:kANReadLaterTypeInstapaper];
            [defaults setObject:@"Instapaper" forKey:@"prefReadLater"];
            [defaults synchronize];
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
    
    // show the cap for the top cell.
    if ([streamData count] > 0)
        hv.cellTopImage.hidden = NO;
    else
        hv.cellTopImage.hidden = YES;
}

- (void) unpinHeaderView
{
    [super unpinHeaderView];
    
    // do custom handling for the header view
    ANStreamHeaderView *hv = (ANStreamHeaderView *)self.headerView;
    [[hv activityIndicator] stopAnimating];
    // show the cap for the top cell.
    if ([streamData count] > 0)
        hv.cellTopImage.hidden = NO;
    else
        hv.cellTopImage.hidden = YES;
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
    if (!_hasFirstLoadOccurred) return;
    
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
    
    _hasFirstLoadOccurred = YES;
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

- (void)replyToFromStream:(id)sender
{
    if (actionBarRow == -1)
        return;
    NSDictionary *postData = [streamData objectAtIndex:actionBarRow];
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] initWithPostData:postData postMode:ANPostModeReply];
    [self presentModalViewController:postView animated:YES];
}

- (void)repostFromStream:(id)sender
{
    if (actionBarRow == -1)
        return;
    NSDictionary *postData = [streamData objectAtIndex:actionBarRow];
    ANPostStatusViewController *postView = [[ANPostStatusViewController alloc] initWithPostData:postData postMode:ANPostModeRepost];
    [self presentModalViewController:postView animated:YES];
}

- (void)showConversation:(id)sender
{
    if (actionBarRow == -1)
        return;
    NSDictionary *postData = [streamData objectAtIndex:actionBarRow];
    ANPostDetailController *detailController = [[ANPostDetailController alloc] initWithPostData:postData];
    [self.navigationController pushViewController:detailController animated:YES];
}

@end
