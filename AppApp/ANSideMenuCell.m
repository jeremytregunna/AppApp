//
//  ANSideMenuCell.m
//  AppApp
//
//  Created by protozog on 8/14/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANSideMenuCell.h"

@implementation ANSideMenuCell

- (void)awakeFromNib
{
    self.menuTitleLabel.font = [UIFont fontWithName:@"Ubuntu-Bold" size:16.0f];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
