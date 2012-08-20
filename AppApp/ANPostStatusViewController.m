//
//  ANPostStatusViewController.m
//  AppApp
//
//  Created by Zach Holmquist on 8/10/12.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANPostStatusViewController.h"
#import "ANAPICall.h"
#import "NSDictionary+SDExtensions.h"

@interface ANPostStatusViewController ()

-(void) updateCharCountLabel: (NSNotification *)notification;
-(void) registerForNotifications;
-(void) unregisterForNotifications;
@end

@implementation ANPostStatusViewController
{
    NSString *replyToID;
}

@synthesize postText, postTextView, characterCountLabel, postButton, groupView, postData;

- (id)init
{
    self = [super initWithNibName:@"ANPostStatusViewController" bundle:nil];
    if (self) {
        postMode = ANPostModeNew;
    }
    return self;
}

- (id)initWithReplyToID:(NSString *)aReplyToID
{
    self = [super initWithNibName:@"ANPostStatusViewController" bundle:nil];
    if (self) {
        replyToID = aReplyToID;
        postMode = ANPostModeNew; // This is semantically wrong, but we need to prevent that anything is added to the text field until we refactored the calling classes (@ralf)
    }
    return self;
}

- (id)initWithPostData:(NSDictionary *)aPostData postMode:(ANPostMode)aPostMode {
    self = [super initWithNibName:@"ANPostStatusViewController" bundle:nil];
    if (self) {
        postData = aPostData;
        postMode = aPostMode;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForNotifications];
}


-(void) dealloc
{
    [self unregisterForNotifications];
}


-(void) registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCharCountLabel:) name:UITextViewTextDidChangeNotification object:nil];
    [self addObserver:self forKeyPath:@"postText" options:0 context:0];
}

-(void) unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    [self removeObserver:self forKeyPath:@"postText"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"postText"]) {
        postTextView.text = self.postText;
        [self updateCharCountLabel:nil];
    } 
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(applyKeyboardSizeChange:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applyKeyboardSizeChange:) name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(applyKeyboardSizeChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [postTextView becomeFirstResponder];
    switch (postMode) {
        case ANPostModeNew:
            break;
        case ANPostModeReply:
            self.postTextView.text = [self usersMentionedInPostData:postData];
            break;
        case ANPostModeRepost:
        {
            NSString *originalText = [postData stringForKey:@"text"];
            NSString *posterUsername = [postData stringForKeyPath:@"user.username"];
            self.postTextView.text = [NSString stringWithFormat:@"RP @%@: %@", posterUsername, originalText];
            break;
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // support orientation change for writing a new post. 
    return (toInterfaceOrientation==UIInterfaceOrientationPortrait ||
            toInterfaceOrientation==UIInterfaceOrientationLandscapeLeft ||
            toInterfaceOrientation==UIInterfaceOrientationLandscapeRight);
}

-(void) updateCharCountLabel: (NSNotification *) notification
{
    NSInteger textLength = 256 - [postTextView.text length];
    
    // unblock / block post button
    if(textLength > 0 && textLength < 256) {
        postButton.enabled = YES;
    } else {
        postButton.enabled = NO;
    }
    
    characterCountLabel.text = [NSString stringWithFormat:@"%i", textLength];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    postTextView.text = textView.text;
}


-(IBAction)dismissPostStatusViewController:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction) postStatusToAppNet:(id)sender
{
    if([postTextView.text length] < 256)
    {
        
        // TODO: Disable Text View.
        // TODO: Activity Indicator.
        
        // TODO: Add delegate to API, make sure to dismiss *only* when post goes through.
        //       ... and add the post to the status listing -- BKS.
        
        if (replyToID)
        {
            [[ANAPICall sharedAppAPI] makePostWithText:postTextView.text replyToPostID:replyToID uiCompletionBlock:^(id dataObject, NSError *error) {
                SDLog(@"post response = %@", dataObject);
            }];        
        }
        else
        {
            [[ANAPICall sharedAppAPI] makePostWithText:postTextView.text uiCompletionBlock:^(id dataObject, NSError *error) {
                SDLog(@"post response = %@", dataObject);
            }];
        }
        [self dismissPostStatusViewController:nil];
    }
}

#pragma mark -
#pragma Helpers
- (NSString *)usersMentionedInPostData:(NSDictionary *)postData
{
    NSString *posterUsername = [postData stringForKeyPath:@"user.username"];
    
    NSArray *mentions = [postData arrayForKeyPath:@"entities.mentions"];
    NSMutableString *result = [NSMutableString stringWithFormat:@"@%@ ", posterUsername];
    
    for (NSDictionary *mention in mentions)
    {
        // skip ourselves if its a reply to us.
        NSString *userID = [mention stringForKey:@"id"];
        if (![userID isEqualToString:[ANAPICall sharedAppAPI].userID])
        {
            NSString *name = [mention stringForKey:@"name"];
            [result appendFormat:@"@%@ ", name];
        }
    }
    
    return result;
}

#pragma mark - UIKeyboard handling

- (void) applyKeyboardSizeChange:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    NSNumber *animationDuration = [dict valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [dict valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    CGRect newFrame;
    UIView *aViewToResize = self.groupView;
    
    CGRect keyboardEndFrame;
    [[dict valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    keyboardEndFrame = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    newFrame = aViewToResize.frame;
    newFrame.size.height = keyboardEndFrame.origin.y - newFrame.origin.y;
    [UIView animateWithDuration:[animationDuration floatValue]
                          delay:0.0
                        options:[curve integerValue]
                     animations:^{
                         aViewToResize.frame = newFrame;
                     }
                     completion:NULL];
}


@end
