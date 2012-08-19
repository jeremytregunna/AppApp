//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [searchCell.searchTextField resignFirstResponder];
    [searchCell hideHashTag];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [searchCell.searchTextField resignFirstResponder];
    [searchCell hideHashTag];
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
    // If there is text and we aren't reusing a hash tag
    if (textField.text.length > 0 && ![searchTags containsObject:textField.text])
    {
        // Begin table updates
        [self.tableView beginUpdates];
        
        // Add text to model
        [searchTags insertObject:textField.text atIndex:0];
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
        
        // Reload cells
        [self.tableView endUpdates];

        // Create hashtag controller
        NSString *hashTag = textField.text;
        
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
    
    // Resign first responder
    [searchCell.searchTextField resignFirstResponder];
    
    // Change hashtag
    [searchCell hideHashTag];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [searchCell showHashTag];
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
        [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView endUpdates];
    }
}

@end
