//
//  ANPostStatusViewController.h
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    ANPostModeNew = 1,
    ANPostModeReply,
    ANPostModeRepost
} ANPostMode;

@interface ANPostStatusViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) IBOutlet UIBarButtonItem *postButton;
@property (nonatomic, retain) IBOutlet UILabel *characterCountLabel;
@property (nonatomic, retain) IBOutlet UITextView *postTextView;
@property (nonatomic, retain) IBOutlet UIView *groupView;
@property (nonatomic, retain) NSString *postText;
@property (nonatomic, retain) NSDictionary *postData;

- (id)init;
- (id)initWithReplyToID:(NSString *)aReplyToID;
- (id)initWithPostData:(NSDictionary *)aPostData postMode:(ANPostMode)aPostMode;

- (IBAction)dismissPostStatusViewController:(id)sender;

@end
