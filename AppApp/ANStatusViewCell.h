//
//  ANStatusViewCell.h
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANImageView.h"
#import "ANPostLabel.h"

extern CGFloat const ANStatusViewCellTopMargin;
extern CGFloat const ANStatusViewCellBottomMargin;
extern CGFloat const ANStatusViewCellLeftMargin;
extern CGFloat const ANStatusViewCellUsernameTextHeight;
extern CGFloat const ANStatusViewCellAvatarHeight;
extern CGFloat const ANStatusViewCellAvatarWidth;

@interface ANStatusViewCell : UITableViewCell
{
    CALayer* _leftBorder;
    CALayer* _bottomBorder;
    CALayer* _topBorder;
    CALayer* _avatarConnector;
}
@property (nonatomic, strong) NSDictionary *postData;
@property (nonatomic, readonly) ANImageView *avatarView;
@property (nonatomic, readonly) UIButton *showUserButton;
@property (nonatomic, readonly) ANPostLabel *statusTextLabel;
@property (nonatomic, readonly) UIView* postView;

@end
