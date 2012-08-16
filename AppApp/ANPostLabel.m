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
    NSArray *linkRanges;
    UITapGestureRecognizer *tapRecognizer;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]) != NULL)
    {
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapRecognizer.enabled = NO;
        [self addGestureRecognizer:tapRecognizer];
    }
    return(self);
}

- (id)initWithCoder:(NSCoder *)inCoder
{
    if ((self = [super initWithCoder:inCoder]) != NULL)
    {
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapRecognizer.enabled = NO;
        [self addGestureRecognizer:tapRecognizer];
    }
    return(self);
}

- (void)dealloc
{
    [self removeGestureRecognizer:tapRecognizer];
}

- (void)setText:(NSAttributedString *)inText
{
    if (self.text != inText)
    {
        [super setText:inText];
        
        NSMutableArray *theRanges = [NSMutableArray array];
        [self.text enumerateAttribute:kMarkupLinkAttributeName inRange:(NSRange){ .length = self.text.length } options:0 usingBlock:^(id value, NSRange range, BOOL *stop) {
            if (value != NULL)
            {
                [theRanges addObject:[NSValue valueWithRange:range]];
            }
        }];
        linkRanges = [theRanges copy];

        [self removeGestureRecognizer:tapRecognizer];
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapRecognizer];
        tapRecognizer.enabled = linkRanges.count > 0;
    }
}

- (void)setEnabled:(BOOL)inEnabled
{
    [super setEnabled:inEnabled];
    
    tapRecognizer.enabled = inEnabled;
}

#pragma mark -

- (void)tap:(UITapGestureRecognizer *)inGestureRecognizer
{
    CGPoint theLocation = [inGestureRecognizer locationInView:self];
    theLocation.x -= self.insets.left;
    theLocation.y -= self.insets.top;
    
    NSRange theRange;
    NSDictionary *theAttributes = [self attributesAtPoint:theLocation effectiveRange:&theRange];
    NSString *theType = [theAttributes objectForKey:@"ANPostLabelAttributeType"];
    NSString *theValue = [theAttributes objectForKey:@"ANPostLabelAttributeValue"];

    if (theValue && theType)
    {
        if (self.tapHandler != NULL)
        {
            self.tapHandler(theRange, theType, theValue);
        }
    }
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
    // example of deleted post id: 70201
    
    _postData = postData;
    
    NSString *text = [_postData stringForKey:@"text"];
    if (!text || [text length] == 0)
        text = @"[deleted post]";
    NSMutableAttributedString *postString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSArray *hashtags = [_postData arrayForKeyPath:@"entities.hashtags"];
    NSArray *links = [_postData arrayForKeyPath:@"entities.links"];
    NSArray *mentions = [_postData arrayForKeyPath:@"entities.mentions"];
    
    [self addAttributes:hashtags key:@"name" type:@"hashtag" attributedString:postString];
    [self addAttributes:links key:@"url" type:@"link" attributedString:postString];
    [self addAttributes:mentions key:@"id" type:@"name" attributedString:postString];
    
    self.text = postString;
}

@end
