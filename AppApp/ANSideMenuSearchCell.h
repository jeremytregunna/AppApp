//
//  ANSideMenuSearchCell.h
//  AppApp
//
//  Created by protozog on 8/18/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ANSideMenuSearchCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIImageView *hashTagImageView;

- (void)showHashTag;
- (void)hideHashTag;

@end
