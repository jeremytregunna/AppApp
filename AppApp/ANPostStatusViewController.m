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
#import "SVProgressHUD.h"
#import "UIAlertView+SDExtensions.h"

@interface ANPostStatusViewController ()

-(void) updateCharCountLabel: (NSNotification *)notification;
-(void) registerForNotifications;
-(void) unregisterForNotifications;
@end

@implementation ANPostStatusViewController
{
    NSString *replyToID;
    UIImage *postImage;
    NSDictionary *postData;
    ANPostMode postMode;
    __weak IBOutlet UIButton *postImageButton;
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
        replyToID = [postData stringForKeyPath:@"id"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerForNotifications];
    postImageButton.hidden = YES;
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
            self.postTextView.text = [self usersMentionedInPostData];
            break;
        case ANPostModeRepost:
        {
            NSString *originalText = [postData stringForKey:@"text"];
            NSString *posterUsername = [postData stringForKeyPath:@"user.username"];
            self.postTextView.text = [NSString stringWithFormat:@"RP @%@: %@", posterUsername, originalText];
            self.postTextView.selectedRange = NSMakeRange(0,0);
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
    
    // account for the imgur url.
    if (postImage)
        textLength -= 29;
    
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

- (void)internalPerformADNPost
{
    if([postTextView.text length] < 256)
    {
        if (replyToID)
        {
            [[ANAPICall sharedAppAPI] makePostWithText:postTextView.text replyToPostID:replyToID uiCompletionBlock:^(id dataObject, NSError *error) {
                SDLog(@"post response = %@", dataObject);
                [SVProgressHUD dismiss];
            }];
        }
        else
        {
            [[ANAPICall sharedAppAPI] makePostWithText:postTextView.text uiCompletionBlock:^(id dataObject, NSError *error) {
                SDLog(@"post response = %@", dataObject);
                [SVProgressHUD dismiss];
            }];
        }
    }
}

-(IBAction)dismissPostStatusViewController:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction) postStatusToAppNet:(id)sender
{
    if([postTextView.text length] < 256)
    {
        [self.postTextView resignFirstResponder];
        if (postImage)
        {
            [SVProgressHUD showWithStatus:@"Uploading image..." maskType:SVProgressHUDMaskTypeBlack];
            [[ANAPICall sharedAppAPI] uploadImage:postImage caption:@"" uiCompletionBlock:^(id dataObject, NSError *error) {
                NSString *urlForImage = [dataObject stringForKeyPath:@"upload.links.original"];
                if (urlForImage)
                {
                    NSString *newPostText = [NSString stringWithFormat:@"%@ %@", postTextView.text, urlForImage];
                    postTextView.text = newPostText;

                    [self internalPerformADNPost];
                    [self dismissPostStatusViewController:nil];
                }
                else
                {
                    [UIAlertView alertViewWithTitle:@"Image upload failed" message:@"Sorry, it appears Imgur is down for maintenance or overloaded."];
                }
                [SVProgressHUD dismiss];
            }];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Posting..." maskType:SVProgressHUDMaskTypeBlack];
            [self internalPerformADNPost];
            [self dismissPostStatusViewController:nil];
        }
    }
}

- (IBAction)photoAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take photo", @"Choose from library", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Helpers

- (NSString *)usersMentionedInPostData
{
    if (!postData)
        return @"";
    
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

- (IBAction)hashAction:(id)sender
{
    postTextView.text = [NSString stringWithFormat:@"%@#", postTextView.text];
}

- (IBAction)clearPhotoAction:(id)sender
{
}

#pragma mark - Action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    switch (buttonIndex)
    {
            // take photo
        case 0:
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            break;
            
            // choose photo
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            break;
            
            // cancel = index 2.
        default:
            break;
    }
    
    if (buttonIndex < 2)
    {
        [self presentModalViewController:picker animated:YES];
    }
}

#pragma mark - UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    postImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (postImage)
        postImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (postImage)
    {
        postImageButton.hidden = NO;
        [postImageButton setImage:postImage forState:UIControlStateNormal];
        [self updateCharCountLabel:nil];
    }
    [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - UIKeyboard handling

- (void) applyKeyboardSizeChange:(NSNotification *)notification{
    /*NSDictionary *dict = [notification userInfo];
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
                     completion:NULL];*/
}


- (void)viewDidUnload
{
    postImageButton = nil;
    [super viewDidUnload];
}

@end
