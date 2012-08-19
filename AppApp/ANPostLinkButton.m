//
//  ANPostLinkButton.m
//  AppApp
//
//  Created by brandon on 8/18/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANPostLinkButton.h"

@implementation ANPostLinkButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        //self.backgroundColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.25];
        self.titleLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
