//
//  ANPostLabel.m
//  AppApp
//
//  Created by brandon on 8/14/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANPostLabel.h"
#import "CCoreTextLabel_HTMLExtensions.h"
#import "CMarkupValueTransformer.h"
#import "NSAttributedString_Extensions.h"
#import <CoreText/CoreText.h>
#import "NSDictionary+SDExtensions.h"

@implementation ANPostLabel
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    return self;
}

- (void)addAttributes:(NSArray *)items key:(NSString *)key type:(NSString *)type attributedString:(NSMutableAttributedString *)attrString
{
    for (NSDictionary *item in items)
    {
        NSUInteger pos = [item unsignedIntegerForKey:@"pos"];
        NSUInteger len = [item unsignedIntegerForKey:@"len"];
        NSString *keyValue = [item stringForKey:key];
        NSRange range = { .location = pos, .length = len };
        
        NSDictionary *theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       (__bridge id)[UIColor colorWithRed:60.0/255.0 green:123.0/255.0 blue:184.0/255.0 alpha:1.0].CGColor, (__bridge NSString *)kCTForegroundColorAttributeName,
                                       type, @"ANPostLabelAttributeType",
                                       keyValue, @"ANPostLabelAttributeValue",
                                       NULL];

        [attrString setAttributes:theAttributes range:range];
    }
}

- (void)setPostData:(NSDictionary *)postData
{
    _postData = postData;
    
    NSString *text = [_postData stringForKey:@"text"];
    NSMutableAttributedString *postString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSArray *hashtags = [_postData arrayForKeyPath:@"entities.hashtags"];
    NSArray *links = [_postData arrayForKeyPath:@"entities.links"];
    NSArray *mentions = [_postData arrayForKeyPath:@"entities.mentions"];
    
    [self addAttributes:hashtags key:@"name" type:@"hashtag" attributedString:postString];
    [self addAttributes:links key:@"url" type:@"link" attributedString:postString];
    [self addAttributes:mentions key:@"name" type:@"name" attributedString:postString];
    
    self.text = postString;
}

- (void)tap:(UITapGestureRecognizer *)inGestureRecognizer
{
    CGPoint theLocation = [inGestureRecognizer locationInView:self];
    theLocation.x -= self.insets.left;
    theLocation.y -= self.insets.top;
    
    NSRange theRange;
    NSDictionary *theAttributes = [self attributesAtPoint:theLocation effectiveRange:&theRange];
    NSString *type = [theAttributes objectForKey:@"ANPostLabelAttributeType"];
    NSString *value = [theAttributes objectForKey:@"ANPostLabelAttibuteValue"];
    
    NSURL *link = nil;
    if ([type isEqualToString:@"hashtags"])
        
    if (theLink != NULL)
    {
        if (self.URLHandler != NULL)
        {
            self.URLHandler(theRange, theLink);
        }
    }
}

@end
