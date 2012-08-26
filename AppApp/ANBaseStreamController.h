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
#import "STableViewController.h"
#import "ANAPICall.h"
#import "ANViewControllerProtocol.h"
#import "ANStatusViewCell.h"
#import "ANReadLaterManager.h"

@interface ANBaseStreamController : STableViewController<ANViewControllerProtocol, UIActionSheetDelegate, ANReadLaterDelegate>
{
@protected
    NSMutableArray *streamData;
    NSIndexPath *newSelection;
    NSIndexPath *currentSelection;
    bool toolbarIsVisible;
    UIView *currentToolbarView;
    UIButton *btnConversation;
    UIButton *btnReply;
    UIButton *btnRepost;
}

@property (nonatomic, readonly) NSString *sideMenuTitle;
@property (nonatomic, readonly) NSString *sideMenuImageName;
@property (nonatomic, retain) UIView *currentToolbarView;
@property (nonatomic, retain) UIButton *btnConversation;
@property (nonatomic, retain) UIButton *btnReply;
@property (nonatomic, retain) UIButton *btnRepost;

- (BOOL)refresh;
- (void)updateTopWithData:(id)dataObject;
- (void)updateBottomWithData:(id)dataObject;
@end
