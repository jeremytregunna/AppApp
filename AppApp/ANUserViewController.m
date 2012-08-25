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

#import "ANUserViewController.h"
#import "SDImageView.h"
#import "ANAPICall.h"
#import "SVProgressHUD.h"
#import "UILabel+SDExtensions.h"
#import "NSDictionary+SDExtensions.h"
#import "UIAlertView+SDExtensions.h"
#import "ANUserPostsController.h"
#import "ANUserListController.h"

#import <QuartzCore/QuartzCore.h>

@interface ANUserViewController ()

@end

@implementation ANUserViewController
{
    NSString *userID;
    NSDictionary *userData;
    NSArray *followersList;
    NSArray *followingList;
    NSArray *mutedList;
    
    CGFloat initialCoverImageYOffset;

    __weak IBOutlet ANImageView *userImageView;
    __weak IBOutlet ANImageView *coverImageView;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *usernameLabel;
    __weak IBOutlet UILabel *bioLabel;
    __weak IBOutlet UIView *topCoverView;
}

- (id)init
{
    self = [super initWithNibName:@"ANUserViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.title = @"Me";
        
        userID = [ANAPICall sharedAppAPI].userID;
    }
    return self;
}

- (id)initWithUserDictionary:(NSDictionary *)userDictionary
{
    self = [super initWithNibName:@"ANUserViewController" bundle:nil];
    
    userData = userDictionary;
    userID = [userData stringForKey:@"id"];
    self.title = [userData objectForKey:@"username"];

    return self;
}

- (id)initWithUsername:(NSString *)username
{
    self = [super initWithNibName:@"ANUserViewController" bundle:nil];
    
    userID = username;
    self.title = username;
    
    return self;
}

- (NSString *)sideMenuTitle
{
    return @"Me";
}

- (NSString *)sideMenuImageName
{
    return @"sidemenu_usermentions_icon";
}

- (void)configureFromUserData
{
    
    NSLog(@"%@",[userData valueForKeyPath:@"follows_you"] );
    
    userImageView.imageURL = [userData valueForKeyPath:@"avatar_image.url"];
    coverImageView.imageURL = [userData valueForKeyPath:@"cover_image.url"];
    
    nameLabel.text = [userData objectForKey:@"name"];
    usernameLabel.text = [NSString stringWithFormat:@"@%@", [userData objectForKey:@"username"]];
    
    // Check for empty descriptions to avoid crashing by passing NSNull into label
    NSString *bioText = [userData valueForKeyPath:@"description.text"];
    if (bioText == (id)[NSNull null] || bioText.length == 0) {
        bioLabel.text = @"";
    } else {
        bioLabel.text = bioText;
    }
    // compute height of bio line.
    CGSize bioSize = [bioLabel.text sizeWithFont:bioLabel.font constrainedToSize:CGSizeMake(197,HUGE_VALF)];
    CGRect frame = bioLabel.frame;
    frame.size.height = MAX(bioSize.height,25.0);
    bioLabel.frame = frame;
    frame = topCoverView.frame;
    frame.size.height = MAX(bioSize.height,30.0) + 10.0;
    topCoverView.frame = frame;
    UIView* tableHeader = self.tableView.tableHeaderView;
    frame = self.tableView.tableHeaderView.frame;
    frame.size.height = topCoverView.frame.origin.y + topCoverView.frame.size.height;
    self.tableView.tableHeaderView.frame = frame;
    self.tableView.tableHeaderView =  tableHeader;
   
    
    if (![self isThisUserMe:userID])
    {
        if ([self doIFollowThisUser])
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAction:)];
        else
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followAction:)];
    }
   
    [self.tableView reloadData];
}

- (void)fetchDataFromUserID
{
    [SVProgressHUD showWithStatus:@"Fetching user info"];
    
    if (!userID)
        userID = [ANAPICall sharedAppAPI].userID;
    
    [[ANAPICall sharedAppAPI] getUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
        if (![[ANAPICall sharedAppAPI] handledError:error dataObject:dataObject view:self.view])
        {
            SDLog(@"user data = %@", dataObject);
            
            // Check if we have errors.
            if (!error && [dataObject objectForKey:@"error"] == nil) {
                userData = (NSDictionary *)dataObject;
                [self configureFromUserData];
                [self fetchFollowData];
            } else {
                //TODO: Show an error
            }
        }
        [SVProgressHUD dismiss];
    }];
    
}

- (BOOL)isThisUserMe:(NSString *)thisUsersID
{
    if ([thisUsersID isEqualToString:[ANAPICall sharedAppAPI].userID])
        return YES;
    return NO;
}

- (BOOL)doIFollowThisUser
{
    BOOL result = [userData boolForKey:@"you_follow"];
    return result;
}

- (BOOL)doesThisUserFollowMe
{
    BOOL result = [userData boolForKey:@"follows_you"];
    return result;
}

- (BOOL)doIMuteThisUser
{
    BOOL result = [userData boolForKey:@"you_muted"];
    return result;
}

- (void)fetchFollowData
{
    // TODO: we're doing this here so we can get a users followers/following count.
    
    [[ANAPICall sharedAppAPI] getUserFollowers:userID uiCompletionBlock:^(id dataObject, NSError *error) {
        followersList = (NSArray *)dataObject;
        
        [self.tableView reloadData];
    }];
    
    [[ANAPICall sharedAppAPI] getUserFollowing:userID uiCompletionBlock:^(id dataObject, NSError *error) {
        followingList = (NSArray *)dataObject;

        [self.tableView reloadData];
    }];
    
    if ([self isThisUserMe:userID])
    {
        [[ANAPICall sharedAppAPI] getMutedUsers:^(id dataObject, NSError *error) {
            mutedList = (NSArray *)dataObject;
            
            [self.tableView reloadData];
        }];
    }
}

- (void)followAction:(id)sender
{
    UIBarButtonItem *button = sender;
    button.enabled = NO;
    [[ANAPICall sharedAppAPI] followUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
        // TODO: check the return here to make sure ther wasn't an error before we change the button.
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Unfollow" style:UIBarButtonItemStyleBordered target:self action:@selector(unfollowAction:)];
    }];
}

- (void)unfollowAction:(id)sender
{
    UIBarButtonItem *button = sender;
    button.enabled = NO;
    [[ANAPICall sharedAppAPI] unfollowUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
        // TODO: check the return here to make sure ther wasn't an error before we change the button.
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Follow" style:UIBarButtonItemStyleBordered target:self action:@selector(followAction:)];        
    }];
}

- (NSString *)userID
{
    return userID;
}

- (BOOL)refresh
{
    // do nothing.
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.clearsSelectionOnViewWillAppear = YES;
    
    if (!userData)
        [self fetchDataFromUserID];
    else
    {
        [self configureFromUserData];
        [self fetchFollowData];
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //userImageView.layer.cornerRadius = 6.0;

    // Setup shadow for cover image view
    topCoverView.layer.shadowRadius = 10.0f;
    topCoverView.layer.shadowOpacity = 0.4f;
    topCoverView.layer.shadowOffset = CGSizeMake(0.0f, -5.0f);
    
    // Setup shadow for avatar image view
    userImageView.layer.shadowRadius = 2.0f;
    userImageView.layer.shadowOpacity = 0.4f;
    userImageView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
    userImageView.layer.masksToBounds = NO;
    
    CGRect shadowRect = topCoverView.bounds;
    shadowRect.size.height /= 4;
    topCoverView.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowRect].CGPath;
    
    // Set the initial 
    initialCoverImageYOffset = CGRectGetMinY(coverImageView.frame);
    
    // make the cover image darker.
    UIView *darkView = [[UIView alloc] initWithFrame:coverImageView.bounds];
    darkView.backgroundColor = [UIColor blackColor];
    darkView.alpha = 0.4;
    [coverImageView addSubview:darkView];
}

- (void)viewDidUnload
{
    coverImageView = nil;
    userImageView = nil;
    bioLabel = nil;
    nameLabel = nil;
    usernameLabel = nil;
    topCoverView = nil;

    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    // only do this if its the only vc on the stack.  workaround for the side menu keeping it around.
    if ([self.navigationController.viewControllers count] == 1)
        [self fetchDataFromUserID];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row == 0 ? 90.0 : 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        // Configure the cell...
    
    switch (indexPath.row) {
        case 0:
        {
            static NSString *CountCellIdentifier = @"CountCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CountCellIdentifier];
            

            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CountCellIdentifier];
                cell.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,90)];   
                cell.backgroundView.backgroundColor = [UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0];
                
                // posts counter
                UILabel *postCount = [[UILabel alloc] initWithFrame:CGRectMake(0,15,0,40)];
        
                postCount.textAlignment = UITextAlignmentCenter;
                postCount.font = [UIFont fontWithName:@"Ubuntu-Bold" size:38.0];
                postCount.textColor = [UIColor colorWithRed:42.0/255.0 green:66.0/255.0 blue:88.0/255.0 alpha:1.0];
                postCount.backgroundColor = cell.backgroundView.backgroundColor;
                postCount.shadowColor = [UIColor whiteColor];
                postCount.tag = 1;
                postCount.shadowOffset = CGSizeMake(0,1);
                [cell.contentView addSubview:postCount];
               
               
                UILabel *postLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,postCount.frame.size.height+10.0,50,16)];
                postLabel.text = @"posts";
                postLabel.tag = 2;
                postLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
                CGSize size = [postLabel.text sizeWithFont:postLabel.font];
                CGRect frame = postLabel.frame;
                frame.size = size;
                postLabel.frame = frame;
              
                postLabel.textColor = [UIColor colorWithRed:42.0/255.0 green:66.0/255.0 blue:88.0/255.0 alpha:1.0];
                postLabel.backgroundColor = cell.backgroundView.backgroundColor;
                postLabel.shadowColor = [UIColor whiteColor];
                postLabel.shadowOffset = CGSizeMake(0,1);
                [cell.contentView addSubview:postLabel];
                
                //followers counter
                UILabel *followersCount = [[UILabel alloc] initWithFrame:CGRectMake(0,15,0,40)];
                followersCount.text = [userData stringForKeyPath:@"counts.followers"];
                followersCount.textAlignment = UITextAlignmentCenter;
                followersCount.font = [UIFont fontWithName:@"Ubuntu-Bold" size:38.0];
                followersCount.textColor = [UIColor colorWithRed:42.0/255.0 green:66.0/255.0 blue:88.0/255.0 alpha:1.0];
                followersCount.backgroundColor = cell.backgroundView.backgroundColor;
                followersCount.shadowColor = [UIColor whiteColor];
                followersCount.shadowOffset = CGSizeMake(0,1);
                followersCount.tag = 3;
                [cell.contentView addSubview:followersCount];
                
                
                UILabel *followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,followersCount.frame.size.height+10.0,50,16)];
                followersLabel.text = @"followers";
                followersLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
                size = [followersLabel.text sizeWithFont:followersLabel.font];
                frame = followersLabel.frame;
                frame.size = size;
                followersLabel.frame = frame;
                followersLabel.tag = 4;
                
                followersLabel.textColor = [UIColor colorWithRed:42.0/255.0 green:66.0/255.0 blue:88.0/255.0 alpha:1.0];
                followersLabel.backgroundColor = cell.backgroundView.backgroundColor;
                followersLabel.shadowColor = [UIColor whiteColor];
                followersLabel.shadowOffset = CGSizeMake(0,1);
                [cell.contentView addSubview:followersLabel];
                
                //following counter
                UILabel *followingCount = [[UILabel alloc] initWithFrame:CGRectMake(0,15,0,40)];
               
                followingCount.textAlignment = UITextAlignmentCenter;
                followingCount.font = [UIFont fontWithName:@"Ubuntu-Bold" size:38.0];
                followingCount.textColor = [UIColor colorWithRed:42.0/255.0 green:66.0/255.0 blue:88.0/255.0 alpha:1.0];
                followingCount.backgroundColor = cell.backgroundView.backgroundColor;
                followingCount.shadowColor = [UIColor whiteColor];
                followingCount.shadowOffset = CGSizeMake(0,1);
                followingCount.tag = 5;
                [cell.contentView addSubview:followingCount];
                
              
       
                
                UILabel *followingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,postCount.frame.size.height+10.0,50,16)];
                followingLabel.text = @"following";
                followingLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
                followingLabel.tag = 6;
                size = [followingLabel.text sizeWithFont:followingLabel.font];
                frame = followingLabel.frame;
                frame.size = size;
                followingLabel.frame = frame;
                
               
                followingLabel.textColor = [UIColor colorWithRed:42.0/255.0 green:66.0/255.0 blue:88.0/255.0 alpha:1.0];
                followingLabel.backgroundColor = cell.backgroundView.backgroundColor;
                followingLabel.shadowColor = [UIColor whiteColor];
                followingLabel.shadowOffset = CGSizeMake(0,1);
                [cell.contentView addSubview:followingLabel];
                
                //seperators
                UIImage* sepImage = [UIImage imageNamed:@"vertical_seperator"];
                UIImageView* sep = [[UIImageView alloc]
                                    initWithFrame:CGRectMake(110,28,sepImage.size.width,sepImage.size.height)];
                sep.image = sepImage;
                [cell.contentView addSubview:sep];
                sep = [[UIImageView alloc]
                                    initWithFrame:CGRectMake(216,28,sepImage.size.width,sepImage.size.height)];
                sep.image = sepImage;
                [cell.contentView addSubview:sep];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                //buttons for the counters
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(0,0,110,90);
                [button addTarget:self action:@selector(viewPosts:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:button];
                
                button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(110,0,106,90);
                [button addTarget:self action:@selector(viewFollowers:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:button];
                
                button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(216,0,104,90);
                [button addTarget:self action:@selector(viewFollowing:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:button];
            }
            
            UILabel* postCount = (UILabel*)[cell.contentView viewWithTag:1];
            UILabel* postLabel = (UILabel*)[cell.contentView viewWithTag:2];
            
            postCount.text = [userData stringForKeyPath:@"counts.posts"];
            
            CGSize size = [postCount.text sizeWithFont:postCount.font];
            CGRect frame = postCount.frame;
            frame.size = size;
            postCount.frame = frame;
            
            CGPoint center = postCount.center;
            center.x = 52.0;
            postCount.center = center;
            
            center = postLabel.center;
            center.x = postCount.center.x;
            postLabel.center = center;
            
            frame = postLabel.frame;
            frame.origin.y = postCount.frame.origin.y + postCount.frame.size.height-5.0;
            postLabel.frame = frame;
            
            UILabel* followersCount = (UILabel*)[cell.contentView viewWithTag:3];
            UILabel* followersLabel = (UILabel*)[cell.contentView viewWithTag:4];
            followersCount.text = [userData stringForKeyPath:@"counts.followers"];
            
            size = [followersCount.text sizeWithFont:followersCount.font];
            frame = followersCount.frame;
            frame.size = size;
            followersCount.frame = frame;
            
            center = followersCount.center;
            center.x = 160.0;
            followersCount.center = center;
            
            center = followersLabel.center;
            center.x = followersCount.center.x;
            followersLabel.center = center;
            
            frame = followersLabel.frame;
            frame.origin.y = followersCount.frame.origin.y + followersCount.frame.size.height-5.0;
            followersLabel.frame = frame;
            
            UILabel* followingCount = (UILabel*)[cell.contentView viewWithTag:5];
            UILabel* followingLabel = (UILabel*)[cell.contentView viewWithTag:6];
            followingCount.text = [userData stringForKeyPath:@"counts.following"];
            
            size = [followingCount.text sizeWithFont:followingCount.font];
            frame = followingCount.frame;
            frame.size = size;
            followingCount.frame = frame;
            
            center = followingCount.center;
            center.x = 268.0;
            followingCount.center = center;
            
            center = followingLabel.center;
            center.x = followingCount.center.x;
            followingLabel.center = center;
            
            frame = followingLabel.frame;
            frame.origin.y = followingCount.frame.origin.y + followingCount.frame.size.height-5.0;
            followingLabel.frame = frame;
            
            
            return cell;
        }
            break;
        case 1:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            ;
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
            }
            cell.detailTextLabel.text = @"";
            cell.accessoryType = UITableViewCellAccessoryNone;
            if ([self isThisUserMe:userID])
            {
                cell.textLabel.text = @"Muted Users";
                if (mutedList)
                {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%u", mutedList.count];
                    if (mutedList.count > 0)
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
            else
            {
                cell.textLabel.text = @"Muted User";
                BOOL youMuted = [userData boolForKey:@"you_muted"];
                if (youMuted)
                {
                    cell.detailTextLabel.text = @"Yes";
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
                else
                {
                    cell.detailTextLabel.text = @"No";
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            return cell;
        }
            break;
        default:
            break;
    }
    
    return nil;
}


-(void)viewPosts:(id)sender {
     UIViewController* controller = [[ANUserPostsController alloc] initWithUserID:userID];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)viewFollowers:(id)sender {
    if (!followersList)
        return;
    UIViewController* controller = [[ANUserListController alloc] initWithUserArray:followersList];
    controller.title = @"Followers";
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)viewFollowing:(id)sender {
    if (!followingList)
        return;
    UIViewController* controller = [[ANUserListController alloc] initWithUserArray:followingList];
    controller.title = @"Following";
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    UIViewController *controller = nil;
    
    switch (indexPath.row) {
       /* case 0:
            controller = [[ANUserPostsController alloc] initWithUserID:userID];
            [self.navigationController pushViewController:controller animated:YES];
            break;
            
        case 1:
            if (!followersList)
                break;
            controller = [[ANUserListController alloc] initWithUserArray:followersList];
            controller.title = @"Followers";
            [self.navigationController pushViewController:controller animated:YES];
            break;
            
        case 2:
            if (!followingList)
                break;
            controller = [[ANUserListController alloc] initWithUserArray:followingList];
            controller.title = @"Following";
            [self.navigationController pushViewController:controller animated:YES];
            break;
            */
        case 1:
        {
            if ([self isThisUserMe:userID])
            {
                if (!mutedList)
                    break;
                controller = [[ANUserListController alloc] initWithUserArray:mutedList];
                controller.title = @"Muted";
                [self.navigationController pushViewController:controller animated:YES];
            }
            else
            {
                BOOL youMuted = [userData boolForKey:@"you_muted"];
                if (youMuted)
                {
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.detailTextLabel.text = @"No";
                    [[ANAPICall sharedAppAPI] unmuteUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
                        // ...
                    }];
                }
                else
                {
                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.detailTextLabel.text = @"Yes";
                    [[ANAPICall sharedAppAPI] muteUser:userID uiCompletionBlock:^(id dataObject, NSError *error) {
                        // ...
                    }];
                }

            }
        }
            break;
            
        default:
            break;
    }
    
    /*if (controller)
        [self.navigationController pushViewController:controller animated:YES];
    else
    {
        UIAlertView *alert = [UIAlertView alertViewWithTitle:@"Unimplemented" message:@"We're still waiting on app.net to implement the api's for this.  Please bear with us."];
        [alert show];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }*/
}

#pragma mark - 
#pragma mark UIScrollview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Figure out the percent to parallax based on initial image offset
    CGFloat percent = -scrollView.contentOffset.y / (-initialCoverImageYOffset*2);
    
    // Round down down if over 1
    percent = percent > 1 ? 1 : percent;
    
    // if less than eq 0, we're scrolling up. original frame.
    if (percent <= 0) {
        coverImageView.frame = CGRectMake(0.0f, initialCoverImageYOffset, CGRectGetWidth(coverImageView.frame), CGRectGetHeight(coverImageView.frame));
    } else if (percent < 1) {
        
        // calculate target y based on percent
        CGFloat targY = initialCoverImageYOffset + (-initialCoverImageYOffset * percent) + scrollView.contentOffset.y;
        
        // update cover image frame
        coverImageView.frame = CGRectMake(0.0f, targY, CGRectGetWidth(coverImageView.frame), CGRectGetHeight(coverImageView.frame));
    }
}

@end
