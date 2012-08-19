//
//  ANSideMenuHashTagCell.h
//  AppApp
//
//  Created by protozog on 8/18/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANSideMenuCell.h"

@class ANSideMenuHashTagCell;
@protocol ANSideMenuHashTagCellDelegate <NSObject>
- (void)didSelectCloseButtonWithCell:(ANSideMenuHashTagCell *)cell;
@end

@interface ANSideMenuHashTagCell : ANSideMenuCell
- (IBAction)closeButtonPressed:(id)sender;
@property (nonatomic, assign) id<ANSideMenuHashTagCellDelegate>delegate;
@end
