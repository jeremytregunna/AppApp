//
//  ANStatusCell.h
//  AppApp
//
//  Created by brandon on 8/27/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANImageView.h"
#import "ANPostLabel.h"

@interface ANStatusCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ANImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *usernameTextLabel;
@property (weak, nonatomic) IBOutlet ANPostLabel *statusTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *created_atTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *showUserButton;
@property (weak, nonatomic) IBOutlet UIView *postView;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *repostButton;
@property (weak, nonatomic) IBOutlet UIButton *convoButton;

@property (nonatomic, assign) BOOL showActionBar;
@property (nonatomic, strong) NSDictionary *postData;

+ (CGFloat)baseHeight:(BOOL)showActionBar;
+ (CGFloat)baseTextHeight;

@end
