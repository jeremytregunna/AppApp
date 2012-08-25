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

typedef enum
{
    ANPostModeNew = 1,
    ANPostModeReply,
    ANPostModeRepost
} ANPostMode;

@interface ANPostStatusViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (nonatomic, retain) IBOutlet UIBarButtonItem *postButton;
@property (nonatomic, retain) IBOutlet UILabel *characterCountLabel;
@property (nonatomic, retain) IBOutlet UITextView *postTextView;
@property (nonatomic, retain) IBOutlet UIView *groupView;
@property (nonatomic, strong) IBOutlet UIScrollView *suggestionView;
@property (nonatomic, retain) NSString *postText;
@property (nonatomic, retain) NSDictionary *postData;

- (id)init;
- (id)initWithReplyToID:(NSString *)aReplyToID;
- (id)initWithPostData:(NSDictionary *)aPostData postMode:(ANPostMode)aPostMode;

- (IBAction)dismissPostStatusViewController:(id)sender;

@end
