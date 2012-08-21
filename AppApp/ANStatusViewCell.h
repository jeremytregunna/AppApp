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

#import <UIKit/UIKit.h>
#import "ANImageView.h"
#import "ANPostLabel.h"

extern CGFloat const ANStatusViewCellTopMargin;
extern CGFloat const ANStatusViewCellBottomMargin;
extern CGFloat const ANStatusViewCellLeftMargin;
extern CGFloat const ANStatusViewCellUsernameTextHeight;
extern CGFloat const ANStatusViewCellAvatarHeight;
extern CGFloat const ANStatusViewCellAvatarWidth;

@interface ANStatusViewCell : UITableViewCell
{
    CALayer* _leftBorder;
    CALayer* _bottomBorder;
    CALayer* _topBorder;
    CALayer* _avatarConnector;
}
@property (nonatomic, strong) NSDictionary *postData;
@property (nonatomic, readonly) ANImageView *avatarView;
@property (nonatomic, readonly) UIButton *showUserButton;
@property (nonatomic, readonly) ANPostLabel *statusTextLabel;
@property (nonatomic, readonly) UIView* postView;

@end
