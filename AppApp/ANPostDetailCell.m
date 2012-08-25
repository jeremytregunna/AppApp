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

#import <QuartzCore/QuartzCore.h>
#import "ANPostDetailCell.h"

@interface ANPostDetailCell ()
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@end

@implementation ANPostDetailCell

@synthesize postLabel;
@synthesize userImageView;
@synthesize nameLabel;
@synthesize usernameLabel;
@synthesize replyButton;
@synthesize repostButton;
@synthesize userButton;
@synthesize topView;
@synthesize arrowImageView;
@synthesize bottomView;

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self addObserver:self forKeyPath:@"topView.frame" options:NSKeyValueObservingOptionOld context:NULL];
    [self addObserver:self forKeyPath:@"bottomView.frame" options:NSKeyValueObservingOptionOld context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"topView.frame"];
    [self removeObserver:self forKeyPath:@"bottomView.frame"];
}

- (void)drawTopShadow
{
    CGFloat baseHeight = CGRectGetHeight(self.topView.frame);
    CGFloat baseWidth = CGRectGetWidth(self.topView.frame);
    CGFloat arrowMinX = CGRectGetMinX(self.arrowImageView.frame);
    UIBezierPath *path = [UIBezierPath bezierPath];

    [path moveToPoint:CGPointMake(0, baseHeight)];
    [path addLineToPoint:CGPointMake(arrowMinX, baseHeight)];
    [path addLineToPoint:CGPointMake(arrowMinX + self.arrowImageView.frame.size.width / 2, baseHeight + self.arrowImageView.frame.size.height)];
    [path addLineToPoint:CGPointMake(arrowMinX + self.arrowImageView.frame.size.width, baseHeight)];
    [path addLineToPoint:CGPointMake(baseWidth, baseHeight)];
    [path addLineToPoint:CGPointMake(baseWidth, baseHeight - 4)];
    [path addLineToPoint:CGPointMake(0, baseHeight - 4)];

    self.topView.layer.shadowOffset = CGSizeMake(0, 2);
    self.topView.layer.shadowRadius = 2;
    self.topView.layer.shadowOpacity = 0.7f;
    self.topView.layer.shadowPath = path.CGPath;
    self.topView.layer.masksToBounds = NO;
}

- (void)drawBottomShadow
{
    self.bottomView.layer.shadowOffset = CGSizeMake(0, -2);
    self.bottomView.layer.shadowRadius = 2;
    self.bottomView.layer.shadowOpacity = 0.7;
    self.bottomView.layer.masksToBounds = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"topView.frame"])
        [self drawTopShadow];
    else if([keyPath isEqualToString:@"bottomView.frame"])
        [self drawBottomShadow];
}

@end
