/*
 Copyright (c) 2012 T. Chroma, M. Herzog, N. Pannuto, J.Pittman, R. Rottmann, B. Sneed, V. Speelman
 The AppApp source code is distributed under the The MIT License (MIT) license.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 associated documentation files (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
 subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial
 portions of the Software.
 
 Any end-user product or application build based on this code, must include the following acknowledgment:
 
 "This product includes software developed by the original AppApp team and its contributors", in the software
 itself, including a link to www.app-app.net.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
*/

#import "ANPostLabel.h"
#import "ANPostLinkButton.h"
#import "NSAttributedString+HTML.h"
#import "NSDictionary+SDExtensions.h"
#import "DTCoreTextConstants.h"
#import "NSString+HTML.h"
#import "PocketAPI.h"

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

- (void)executeLongPressHandler:(UILongPressGestureRecognizer *)longPressRecognizer
{
    if(longPressRecognizer.state == UIGestureRecognizerStateBegan)
    {
        ANPostLinkButton *button = (ANPostLinkButton *)longPressRecognizer.view;
        _longPressHandler(button.type, button.value);
    }
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
    // This long press gesture recognizer is added so we can perform some action like
    // popping up an action sheet so a user can save a URL via Pocket. @jtregunna
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(executeLongPressHandler:)];
    [button addGestureRecognizer:longPressRecognizer];

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
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);

        if (len > [attrString length]-1)
            len = [attrString length]-1;
        NSDictionary *theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                       (__bridge id)[UIColor colorWithRed:60.0/255.0 green:123.0/255.0 blue:184.0/255.0 alpha:1.0].CGColor, (__bridge NSString *)kCTForegroundColorAttributeName,
                                       (__bridge id)ctFont, kCTFontAttributeName,
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

    NSArray *rawHashtags = [_postData arrayForKeyPath:@"entities.hashtags"];
    NSArray *links = [_postData arrayForKeyPath:@"entities.links"];
    NSArray *rawMentions = [_postData arrayForKeyPath:@"entities.mentions"];
    
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.0f];
    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    [postString addAttribute:(NSString*)kCTFontAttributeName
                        value:(__bridge id)ctFont
                        range:NSMakeRange(0, postString.length-1)];
    CFRelease(ctFont);
    
    [postString addAttribute:(NSString *)kCTForegroundColorAttributeName
                       value:(id)[UIColor colorWithRed:30.0/255.0 green:88.0/255.0 blue:119.0/255.0 alpha:1.0].CGColor
                       range:NSMakeRange(0, postString.length-1)];
    
    /* 
     @ralf: 
     I had to add this because occasionally ADN does return the wrong start position (pos) for hashtags and mentions.
     This seems to happen when there are additional unicode characters in a post which will not be displayed.
     AppApp crashed if that lead to an edge condition, where position + length is out of the boundaries of the text,
     e.g. when a hashtag is at the end of a post. 
     
     We very likely have to check on those for links, too, but they are not as easy to be identified as a # or @.
     
     Example Post ID that caused a crash:
     170655
     
     Text:
     &#55357;&#56891; RP @eay: Think about this: Twitter wasn&apos;t able to create something like Smart Push Notification in three years (since Apple introduced the Push Notification Service), while @ralf, @sneakyness &amp; Co. did it in 10 days! #AppApp
     
     Seems as if the unicode entities do not get parsed correctly by ADN API. Opened an issue with App.net https://github.com/appdotnet/api-spec/issues/131.
    */
    NSMutableArray *cleanedHashtags = [[NSMutableArray alloc] initWithCapacity:0];
    [rawHashtags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int pos = (int)[(NSDictionary *)obj integerForKey:@"pos"];
        if ([text characterAtIndex:pos] == '#') {
            [cleanedHashtags addObject:obj];
        }
    }];
    
    NSMutableArray *cleanedMentions = [[NSMutableArray alloc] initWithCapacity:0];
    [rawMentions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int pos = (int)[(NSDictionary *)obj integerForKey:@"pos"];
        if ([text characterAtIndex:pos] == '@') {
            [cleanedMentions addObject:obj];
        }
    }];
    
    [self addAttributes:cleanedHashtags key:@"name" type:@"hashtag" attributedString:postString];
    [self addAttributes:links key:@"url" type:@"link" attributedString:postString];
    [self addAttributes:cleanedMentions key:@"id" type:@"name" attributedString:postString];
    
    self.attributedString = postString;
    [self relayoutText];
    [self layoutSubviews];
}

@end
