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

@implementation ANSideMenuController
{
    ANUserStreamController *userStream;
    ANUserMentionsController *mentionsStream;
    ANGlobalStreamController *globalStream;
    ANUserViewController *userInfo;
}

- (id)init
{
    self = [super init];
    
    userStream = [[ANUserStreamController alloc] init];
    mentionsStream = [[ANUserMentionsController alloc] init];
    globalStream = [[ANGlobalStreamController alloc] init];
    userInfo = [[ANUserViewController alloc] init];
    
    _navigationArray = @[userStream, mentionsStream, globalStream, userInfo];

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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"sideMenuCell";
    
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


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewController *controller = [_navigationArray objectAtIndex:indexPath.row];
    
    NSArray *controllers = [NSArray arrayWithObject:controller];
    [self updateOnlyCurrentTableViewToScrollToTop:controller];
    [MFSideMenuManager sharedManager].navigationController.viewControllers = controllers;
    [MFSideMenuManager sharedManager].navigationController.menuState = MFSideMenuStateHidden;
}

- (void)updateOnlyCurrentTableViewToScrollToTop:(UITableViewController *)current {
	for (UITableViewController *c in _navigationArray) {
		if ([c isViewLoaded]) {
			c.tableView.scrollsToTop = (current==c);
		}
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 53.0f;
}

@end
