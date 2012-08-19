//
//  SideMenuViewController.h
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import <UIKit/UIKit.h>

#import "ANSideMenuHashTagCell.h"

@interface ANSideMenuController : UITableViewController <UITextFieldDelegate, ANSideMenuHashTagCellDelegate>

@property (nonatomic, readonly) NSArray *navigationArray;

@end