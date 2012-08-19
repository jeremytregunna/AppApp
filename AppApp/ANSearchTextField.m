//
//  ANSearchTextField.m
//  AppApp
//
//  Created by protozog on 8/18/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANSearchTextField.h"

@implementation ANSearchTextField

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [[UIColor colorWithRed:24/255.0f green:49/255.0f blue:69/255.0f alpha:1.0f] setFill];
    [self.placeholder drawInRect:rect withFont:[UIFont fontWithName:@"Ubuntu-Bold" size:16.0]];
}

@end
