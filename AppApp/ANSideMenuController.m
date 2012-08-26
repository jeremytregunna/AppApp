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

#import "ANSideMenuController.h"
#import "MFSideMenu.h"
#import "ANGlobalStreamController.h"
#import "ANUserStreamController.h"
#import "ANUserMentionsController.h"
#import "ANUserViewController.h"
#import "ANSideMenuCell.h"
#import "NSObject+SDExtensions.h"
#import "ANSideMenuSearchCell.h"
#import "ANHashtagStreamController.h"
#import "ANSideMenuHashTagCell.h"

// Key for storing tags in defaults
NSString *const ANSideMenuControllerSearchTagsKey = @"ANSideMenuControllerSearchTagsKey";

@implementation ANSideMenuController
{
    ANUserStreamController *userStream;
    ANUserMentionsController *mentionsStream;
    ANGlobalStreamController *globalStream;
    ANUserViewController *userInfo;
    ANSideMenuSearchCell *searchCell;
    NSMutableArray *searchTags;
}

- (id)init
{
    self = [super init];
    
    userStream = [[ANUserStreamController alloc] init];
    mentionsStream = [[ANUserMentionsController alloc] init];
    globalStream = [[ANGlobalStreamController alloc] init];
    userInfo = [[ANUserViewController alloc] init];

    _navigationArray = @[userStream, mentionsStream, globalStream, userInfo];   
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults objectForKey:ANSideMenuControllerSearchTagsKey]) {
        searchTags = [[defaults objectForKey:ANSideMenuControllerSearchTagsKey] mutableCopy];
    } else {
        searchTags = [[NSMutableArray alloc] init];    
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setScrollsToTop:NO];
    
    // Set up title
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:7/255.0f green:92/255.0f blue:127/255.0f alpha:1.0f];

    [self.tableView setNeedsLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustsFrameWhenStatusBarChanges:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [searchCell.searchTextField resignFirstResponder];
    [searchCell hideHashTag];
    searchCell.searchTextField.text = @"";
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [searchCell.searchTextField resignFirstResponder];
    [searchCell hideHashTag];
    searchCell.searchTextField.text = @"";    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return  4;
    } else if (section == 1) {
        return 1 + [searchTags count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ANSideMenuCell";
    static NSString *SearchCellIdentifier = @"ANSideMenuSearchCell";
    static NSString *HashTagCellIdentifier = @"ANSideMenuHashTagCell";
    
    // Main menu selection
    if (indexPath.section == 0)
    {
        ANSideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [ANSideMenuCell loadFromNib];
        }
        
        id<ANViewControllerProtocol> controller = [_navigationArray objectAtIndex:indexPath.row];
        cell.menuTitleLabel.text = [controller.sideMenuTitle uppercaseString];
        
        if ([controller respondsToSelector:@selector(sideMenuImageName)]) {
            cell.menuIconImageView.image = [UIImage imageNamed:controller.sideMenuImageName];
        } else {
            cell.menuIconImageView.image = nil;
        }
        
        return cell;
    }
    // Search section
    else if (indexPath.section == 1)
    {
        // Search Header Cell
        if (indexPath.row == 0)
        {
            ANSideMenuSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier];
            
            if (cell == nil)
            {
                cell = [ANSideMenuSearchCell loadFromNib];
                searchCell = cell;
            }
            
            cell.searchTextField.delegate = self;
            
            return cell;
        }
        // Hash Tag Cell
        else
        {
            ANSideMenuHashTagCell *cell = [tableView dequeueReusableCellWithIdentifier:HashTagCellIdentifier];
            if (cell == nil)
            {
                cell = [ANSideMenuHashTagCell loadFromNib];
                cell.delegate = self;
            }
            
            NSString *title = [searchTags objectAtIndex:indexPath.row - 1];
            cell.menuTitleLabel.text = title;
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Selected item from main section
    if (indexPath.section == 0)
    {
        UITableViewController *controller = [_navigationArray objectAtIndex:indexPath.row];
        
        NSArray *controllers = [NSArray arrayWithObject:controller];
        [self updateOnlyCurrentTableViewToScrollToTop:controller];
        [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
        [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;        
    }
    // Selected something in search section
    else if (indexPath.section == 1 && indexPath.row > 0)
    {
        // Get the selected hash tag
        NSString *hashTag = [searchTags objectAtIndex:indexPath.row - 1];

        // Create hashtag controller
        ANHashtagStreamController *hashTagController = [[ANHashtagStreamController alloc] initWithHashtag:hashTag];
        NSArray *controllers = [NSArray arrayWithObject:hashTagController];
        [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
        [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
    }
}

- (void)updateOnlyCurrentTableViewToScrollToTop:(UITableViewController *)current
{
	for (UITableViewController *c in _navigationArray) {
		if ([c isViewLoaded]) {
			c.tableView.scrollsToTop = (current==c);
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53.0f;
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0 && [[textField.text substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"@"]) {
        [self _handleUsernameSearch:textField.text];
    } else if (textField.text.length > 0){
        NSString *hashtag = textField.text;
        if ([textField.text rangeOfString:@"#"].location == 0) {
            hashtag = [textField.text stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        [self _handleHashTagSearch:hashtag];
    }
    
    // Resign first responder
    [searchCell.searchTextField resignFirstResponder];
    
    // Change hashtag
    [searchCell hideHashTag];
    
    // Clear search field
    searchCell.searchTextField.text = @"";
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // Get new string
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Get first char
    NSString *firstChar = newString.length == 0 ? @"" : [newString substringWithRange:NSMakeRange(0, 1)];
    
    // if string is empty OR the first char is @ or #
    if (newString.length == 0 || (newString.length > 0 && ([firstChar isEqualToString:@"@"] || [firstChar isEqualToString:@"#"]))) {
        [searchCell hideHashTag];
    } else {
        [searchCell showHashTag];
    }
    
    return YES;
}

- (void)_handleUsernameSearch:(NSString *)username
{
    ANUserViewController *userViewController = [[ANUserViewController alloc] initWithUsername:username];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = @[userViewController];
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
}

- (void)_handleHashTagSearch:(NSString *)hashTag
{
    // If there is text and we aren't reusing a hash tag
    if (hashTag.length > 0 && ![searchTags containsObject:hashTag])
    {
        // Begin table updates
        [self.tableView beginUpdates];
        
        // Add text to model
        [searchTags insertObject:hashTag atIndex:0];
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
        
        // Reload cells
        [self.tableView endUpdates];
        
        // Create hashtag controller
        // Set up delay for animation purposes
        NSTimeInterval delayInSeconds = .5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            // Select the cell
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1] animated:NO scrollPosition:UITableViewScrollPositionNone];
            
            ANHashtagStreamController *hashTagController = [[ANHashtagStreamController alloc] initWithHashtag:hashTag];
            NSArray *controllers = [NSArray arrayWithObject:hashTagController];
            //            [self updateOnlyCurrentTableViewToScrollToTop:hashTagController];
            [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
            [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
        });
        
        [self _syncHashTagsToDefaults];
    }
}

// syncs searchTags array to NSUserDefaults
- (void)_syncHashTagsToDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:searchTags forKey:ANSideMenuControllerSearchTagsKey];
    [defaults synchronize];
}

#pragma mark -
#pragma mark HashTagCellDelegate

- (void)didSelectCloseButtonWithCell:(ANSideMenuHashTagCell *)cell
{
    // Grab the indexPath from X'd hash tag
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    // Translate to data
    NSUInteger indexOfObject = path.row - 1;
    
    // Check within bounds
    if (indexOfObject < [searchTags count])
    {
        [self.tableView beginUpdates];
        [searchTags removeObjectAtIndex:indexOfObject];
        [self _syncHashTagsToDefaults];
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}

#pragma mark -
#pragma mark Notification callbacks

- (void)adjustsFrameWhenStatusBarChanges:(NSNotification*)notif
{
    NSValue* valueRect = [[notif userInfo] objectForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect statusBarFrame = [valueRect CGRectValue];
    CGRect frame = self.tableView.frame;
    frame.origin.y = statusBarFrame.size.height;
    frame.size.height = [UIScreen mainScreen].bounds.size.height - statusBarFrame.size.height;
    __weak ANSideMenuController* weakSelf = self;
    [UIView animateWithDuration:0.35 animations:^{
        weakSelf.tableView.frame = frame;
    }];
}

@end
