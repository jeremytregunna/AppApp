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

#import "ANSideMenuSearchCell.h"

@implementation ANSideMenuSearchCell
{
    CGRect initialHashTagImageViewFrame;
    CGRect initialSearchFieldFrame;
    BOOL _hashtagVisible;
}

- (void)awakeFromNib
{
    initialHashTagImageViewFrame = self.hashTagImageView.frame;
    initialSearchFieldFrame = self.searchTextField.frame;
    
    self.searchTextField.font = [UIFont fontWithName:@"Ubuntu-Bold" size:16.0f];
    self.hashTagImageView.alpha = 0.0f;
}

- (void)showHashTag
{
    if (_hashtagVisible) return;
    
    CGRect targHashTagRect = CGRectMake(70.0f, CGRectGetMinY(self.hashTagImageView.frame), CGRectGetWidth(self.hashTagImageView.frame), CGRectGetHeight(self.hashTagImageView.frame));
    
    CGRect targSearchFieldRect = CGRectMake(90.0f, CGRectGetMinY(self.searchTextField.frame), CGRectGetWidth(self.searchTextField.frame), CGRectGetHeight(self.searchTextField.frame));
    
    [UIView animateWithDuration:.35 animations:^{
        self.hashTagImageView.alpha = 1.0f;
        self.searchTextField.frame = targSearchFieldRect;
        self.hashTagImageView.frame = targHashTagRect;
    }];
    
    _hashtagVisible = YES;
}

- (void)hideHashTag
{
    if (!_hashtagVisible) return;
    
    _hashtagVisible = NO;
    
    [UIView animateWithDuration:.25 animations:^{
        self.hashTagImageView.alpha = 0.0f;
        self.searchTextField.frame = initialSearchFieldFrame;
        self.hashTagImageView.frame = initialHashTagImageViewFrame;
    }];
}

@end
