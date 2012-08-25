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

#import "ANUserListController.h"
#import "ANUserViewController.h"
#import "ANUserListCell.h"
#import "NSDictionary+SDExtensions.h"
#import "NSObject+SDExtensions.h"
#import "ANDataStoreController.h"
#import "ReferencedEntity.h"

@interface ANUserListController ()

@property (assign, nonatomic) BOOL isFiltered;
@property (strong, nonatomic) NSMutableArray *filteredUsers;

@end

@implementation ANUserListController
{
    NSArray *userArray;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUserArray:(NSArray *)aUserArray
{
    self = [super initWithNibName:@"ANUserListController" bundle:nil];
    
    userArray = aUserArray;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
//    return [userArray count];
    
    NSInteger items = 0;
    if (self.filteredUsers) {
        items = [self.filteredUsers count];
    } else {
        items = [userArray count];
    }
    
    return items;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"userListCell";
    ANUserListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell = [ANUserListCell loadFromNib];
    
    // Configure the cell...
    NSDictionary *userObject = nil;
    
    if (self.isFiltered) {
        userObject = [self.filteredUsers objectAtIndex:[indexPath row]];
    } else {
        userObject = [userArray objectAtIndex:[indexPath row]];
    }

    // Cache the current username in core data
    ReferencedEntity* re = [ReferencedEntity referencedEntityWithType:ANReferencedEntityTypeUsername name:[userObject stringForKeyPath:@"username"]];
    // Don't care if the save didn't work
    [re save:nil successCallback:nil];

    cell.nameLabel.text = [userObject stringForKey:@"name"];
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", [userObject stringForKeyPath:@"username"]];
    cell.userImageView.imageURL = [userObject stringForKeyPath:@"avatar_image.url"];
    
    // seems like we should use is_following here instead, but this one shows the correct results.
    BOOL follower = [userObject boolForKey:@"follows_you"];
    BOOL following = [userObject boolForKey:@"you_follow"];
    
    if (follower && following) {
        cell.followStatusImage.image = [UIImage imageNamed:@"mutualFollow"];
    } else if (follower) {
        cell.followStatusImage.image = [UIImage imageNamed:@"follower"];
    } else if (following) {
        cell.followStatusImage.image = [UIImage imageNamed:@"following"];
    } else {
        cell.followStatusImage.image = nil;
    }
    
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
    // Navigation logic may go here. Create and push another view controller.
    NSDictionary *userObject = nil;

    if (self.isFiltered) {
        userObject = [self.filteredUsers objectAtIndex:indexPath.row];
    } else {
        userObject = [userArray objectAtIndex:indexPath.row];
    }
    
    ANUserViewController *userController = [[ANUserViewController alloc] initWithUserDictionary:userObject];
    [self.navigationController pushViewController:userController animated:YES];
}

#pragma mark - Search Bar Delegate methods.

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    
    if(text.length == 0) {
        self.isFiltered = NO;
        self.filteredUsers = nil;
        
    } else {
        
        self.isFiltered = YES;
        self.filteredUsers = [[NSMutableArray alloc] init];
        
        NSDictionary *user = nil;
        for (user in userArray) {
                        
            NSRange nameRange = [[user stringForKey:@"name"] rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange usernameRange = [[user objectForKey:@"username"] rangeOfString:text options:NSCaseInsensitiveSearch];
            
            if(nameRange.location != NSNotFound || usernameRange.location != NSNotFound) {
                [self.filteredUsers addObject:user];
            }
            
        }
        
    }
    
    [self.tableView reloadData];
}

@end
