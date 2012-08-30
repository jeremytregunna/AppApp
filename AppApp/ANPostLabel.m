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

#import <CoreText/CoreText.h>
#import "ANPostLabel.h"
#import "NSDictionary+SDExtensions.h"
#import "PocketAPI.h"

@interface TTTAttributedLabel(ANPostLabelExt)
- (NSTextCheckingResult *)linkAtPoint:(CGPoint)p;
@end

@implementation ANPostLabel
{
    UITapGestureRecognizer *tapRecognizer;
    UILongPressGestureRecognizer *longPressRecognizer;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]) != NULL)
    {
        _enableLinks = YES;
        _enableDataDetectors = YES;
        self.userInteractionEnabled = YES;
        self.lineBreakMode = UILineBreakModeWordWrap;
        self.numberOfLines = 0;
        self.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        self.textColor = [UIColor colorWithRed:30.0/255.0 green:88.0/255.0 blue:119.0/255.0 alpha:1.0];
        self.linkAttributes = @{ (NSString *)kCTForegroundColorAttributeName : (id)[UIColor colorWithRed:60.0/255.0 green:123.0/255.0 blue:184.0/255.0 alpha:1.0].CGColor };
        self.activeLinkAttributes = @{ (NSString *)kCTForegroundColorAttributeName : (id)[UIColor colorWithRed:60.0/255.0 green:123.0/255.0 blue:184.0/255.0 alpha:1.0].CGColor };
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHandler:)];
        
        [self addGestureRecognizer:tapRecognizer];
        [self addGestureRecognizer:longPressRecognizer];
    }
    return(self);
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]) != NULL)
    {
        _enableLinks = YES;
        _enableDataDetectors = YES;
        self.userInteractionEnabled = YES;
        self.lineBreakMode = UILineBreakModeWordWrap;
        self.numberOfLines = 0;
        self.font = [UIFont fontWithName:@"Helvetica" size:14.0f];
        self.textColor = [UIColor colorWithRed:30.0/255.0 green:88.0/255.0 blue:119.0/255.0 alpha:1.0];
        self.linkAttributes = @{ (NSString *)kCTForegroundColorAttributeName : (id)[UIColor colorWithRed:60.0/255.0 green:123.0/255.0 blue:184.0/255.0 alpha:1.0].CGColor };
        self.activeLinkAttributes = @{ (NSString *)kCTForegroundColorAttributeName : (id)[UIColor colorWithRed:60.0/255.0 green:123.0/255.0 blue:184.0/255.0 alpha:1.0].CGColor };
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
        longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHandler:)];
        
        [self addGestureRecognizer:tapRecognizer];
        [self addGestureRecognizer:longPressRecognizer];
    }
    return(self);
}

- (void)dealloc
{
    [self removeGestureRecognizer:tapRecognizer];
    [self removeGestureRecognizer:longPressRecognizer];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    NSTextCheckingResult *linkCheck = [self linkAtPoint:point];
    if (linkCheck.URL)
        return result;
    else
        return nil;
}

- (void)tapGestureHandler:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        NSTextCheckingResult *result = [self linkAtPoint:[recognizer locationInView:self]];
        if (_tapHandler && _enableLinks)
            _tapHandler(result.URL);
    }
}

- (void)longPressGestureHandler:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSTextCheckingResult *result = [self linkAtPoint:[recognizer locationInView:self]];
        if (_longPressHandler && _enableLinks)
            _longPressHandler(result.URL);
    }
}

- (void)addMentionLinks:(NSString *)string
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(@[a-zA-Z0-9_]+)" options:0 error:nil];
    __weak typeof(self) blockSelf = self;
    [regex enumerateMatchesInString:string options:NSMatchingCompleted range:NSMakeRange(0, [string length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *user = [string substringWithRange:result.range];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"adnuser://%@", user]];
        [blockSelf addLinkToURL:url withRange:result.range];
    }];
}

- (void)addHashtagLinks:(NSString *)string
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(#[a-zA-Z0-9_-]+)" options:0 error:nil];
    __weak typeof(self) blockSelf = self;
    [regex enumerateMatchesInString:string options:NSMatchingCompleted range:NSMakeRange(0, [string length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSString *hashtag = [string substringWithRange:result.range];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"adnhashtag://%@", hashtag]];
        [blockSelf addLinkToURL:url withRange:result.range];
    }];
}

CTFontRef CTFontCreateFromUIFont(UIFont *font)
{
    CTFontRef ctFont = CTFontCreateWithName((__bridge  CFStringRef)font.fontName,
                                            font.pointSize,
                                            NULL);
    return ctFont;
}

- (void)setPostText:(NSString *)value
{
    // example of deleted post id: 70201
    
    _postText = value;
    
    NSString *text = value;
    if (!text || [text length] == 0)
        text = [@"[deleted post]" mutableCopy];

    if (_enableDataDetectors)
        self.dataDetectorTypes = UIDataDetectorTypeLink;
    else
        self.dataDetectorTypes = UIDataDetectorTypeNone;

    // some CT display optimizations
    NSNumber *kern = [NSNumber numberWithFloat:0];
    CTFontRef fontRef = CTFontCreateFromUIFont([UIFont fontWithName:@"Helvetica" size:14.0f]);
    NSDictionary *attrs = @{
        (NSString *)kCTKernAttributeName : kern,
        (NSString *)kCTFontAttributeName : (__bridge id)fontRef,
        (NSString *)kCTForegroundColorAttributeName : (id)[UIColor colorWithRed:30.0/255.0 green:88.0/255.0 blue:119.0/255.0 alpha:1.0].CGColor
    };
    CFRelease(fontRef);
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:attrs];
    self.text = attrString;
    if (_enableDataDetectors)
    {
        [self addMentionLinks:self.text];
        [self addHashtagLinks:self.text];
    }
}

#pragma mark - TTT delegate methods

@end
