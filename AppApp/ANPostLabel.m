//
//  ANPostLabel.m
//  AppApp
//
//  Created by brandon on 8/14/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANPostLabel.h"
#import "ANPostLinkButton.h"
#import "NSAttributedString+HTML.h"
#import "NSDictionary+SDExtensions.h"
#import "DTCoreTextConstants.h"
#import "NSString+HTML.h"

@implementation ANPostLabel

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]) != NULL)
    {
        self.delegate = self;
        _enableLinks = YES;
        //self.drawDebugFrames = YES;
        self.userInteractionEnabled = YES;
    }
    return(self);
}

- (void)setEnableLinks:(BOOL)enableLinks
{
    if (enableLinks == _enableLinks)
        return;
    
    _enableLinks = enableLinks;
    [self relayoutText];
}

- (void)executeTapHandler:(id)sender
{
    ANPostLinkButton *button = (ANPostLinkButton *)sender;
    _tapHandler(button.type, button.value);
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier frame:(CGRect)frame;
{
    if (!_enableLinks)
        return nil;
    // we're misusing an NSURL here, but i want to modify DTCoreText as little as possible.
    // soon, i hope to do this right and submit a patch.  just trying to get things working again.  -- BKS
    NSString *value = (NSString *)url;
    
    ANPostLinkButton *button = [[ANPostLinkButton alloc] initWithFrame:frame];
    button.minimumHitSize = CGSizeMake(20, 20);
    button.type = identifier;
    button.value = value;
    button.enabled = YES;
    button.userInteractionEnabled = YES;
    [button addTarget:self action:@selector(executeTapHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame;
{
    return nil;
}

- (void)addAttributes:(NSArray *)items key:(NSString *)key type:(NSString *)type attributedString:(NSMutableAttributedString *)attrString
{
    for (NSDictionary *item in items)
    {
        NSUInteger pos = [item unsignedIntegerForKey:@"pos"];
        NSUInteger len = [item unsignedIntegerForKey:@"len"];
        NSString *keyValue = [item stringForKey:key];
        NSRange range = { .location = pos, .length = len };
        if (len > [attrString length]-1)
            len = [attrString length]-1;
        NSDictionary *theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       (__bridge id)[UIColor colorWithRed:60.0/255.0 green:123.0/255.0 blue:184.0/255.0 alpha:1.0].CGColor, (__bridge NSString *)kCTForegroundColorAttributeName,
                                       type, @"ANPostLabelAttributeType",
                                       keyValue, @"ANPostLabelAttributeValue",
                                       type, DTGUIDAttribute,
                                       keyValue, DTLinkAttribute,
                                       NULL];

        [attrString setAttributes:theAttributes range:range];
    }
}

- (void)setPostData:(NSDictionary *)postData
{
    // example of deleted post id: 70201
    
    _postData = postData;
    
    NSMutableString *text = [[[_postData stringForKey:@"text"] stringByAddingHTMLEntities] mutableCopy];
    if (!text || [text length] == 0)
        text = [@"[deleted post]" mutableCopy];
    
    [text replaceOccurrencesOfString:@"\n" withString:@"<br>" options:0 range:NSMakeRange(0, text.length)];
    
    NSData *htmlData = [text dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableAttributedString *postString = [[[NSAttributedString alloc] initWithHTMLData:htmlData documentAttributes:NULL] mutableCopy];

    NSArray *hashtags = [_postData arrayForKeyPath:@"entities.hashtags"];
    NSArray *links = [_postData arrayForKeyPath:@"entities.links"];
    NSArray *mentions = [_postData arrayForKeyPath:@"entities.mentions"];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:12.0f];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    [postString addAttribute:(NSString*)kCTFontAttributeName
                        value:(__bridge id)ctFont
                        range:NSMakeRange(0, postString.length-1)];
    CFRelease(ctFont);
    
    [postString addAttribute:(NSString *)kCTForegroundColorAttributeName
                       value:(id)[UIColor colorWithRed:30.0/255.0 green:88.0/255.0 blue:119.0/255.0 alpha:1.0].CGColor
                       range:NSMakeRange(0, postString.length-1)];
    
    [self addAttributes:hashtags key:@"name" type:@"hashtag" attributedString:postString];
    [self addAttributes:links key:@"url" type:@"link" attributedString:postString];
    [self addAttributes:mentions key:@"id" type:@"name" attributedString:postString];
    
    self.attributedString = postString;
    [self relayoutText];
    [self layoutSubviews];
}

@end
