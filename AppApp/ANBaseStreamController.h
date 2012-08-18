//
//  ANBaseStreamController.h
//  AppApp
//
//  Created by brandon on 8/11/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STableViewController.h"
#import "ANAPICall.h"
#import "ANViewControllerProtocol.h"
#import "ANStatusViewCell.h"
#import "TTTAttributedLabel.h"

@interface ANBaseStreamController : STableViewController<ANViewControllerProtocol,TTTAttributedLabelDelegate>
{
@protected
    NSMutableArray *streamData;
    NSIndexPath *currentSelection;
    UIView* currentToolbarView;
}

@property (nonatomic, readonly) NSString *sideMenuTitle;
@property (nonatomic, readonly) NSString *sideMenuImageName;

- (BOOL)refresh;
- (void)updateTopWithData:(id)dataObject;
- (void)updateBottomWithData:(id)dataObject;
@end
