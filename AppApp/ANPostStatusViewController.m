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
#import "ANPostStatusViewController.h"
#import "ANAPICall.h"
#import "NSDictionary+SDExtensions.h"
#import "SVProgressHUD.h"
#import "UIAlertView+SDExtensions.h"
#import "ANDataStoreController.h"
#import "ReferencedEntity.h"
#import "MKInfoPanel.h"

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

    // Autocomplete
    NSMutableString *currentCapture;
    ANReferencedEntityType currentCaptureType;
    NSRange currentCaptureRange;
    NSArray* currentSuggestions;
}

@synthesize postText, postTextView, characterCountLabel, postButton, groupView, postData, suggestionView;

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

    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.suggestionView.bounds;
    gradientLayer.colors = @[ (id)[[UIColor colorWithRed:94.0f/255.0f green:135.0f/255.0f blue:1.0f alpha:1.0f] CGColor], (id)[[UIColor colorWithRed:54.0f/255.0f green:84.0f/255.0f blue:1.0f alpha:1.0f] CGColor] ];
    [self.suggestionView.layer insertSublayer:gradientLayer atIndex:0];
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
                if (![[ANAPICall sharedAppAPI] handledError:error dataObject:dataObject view:self.view])
                    [self dismissPostStatusViewController:nil];
                [SVProgressHUD dismiss];
            }];
        }
        else
        {
            [[ANAPICall sharedAppAPI] makePostWithText:postTextView.text uiCompletionBlock:^(id dataObject, NSError *error) {
                SDLog(@"post response = %@", dataObject);
                if (![[ANAPICall sharedAppAPI] handledError:error dataObject:dataObject view:self.view])
                    [self dismissPostStatusViewController:nil];
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
                }
                else
                {
                    [MKInfoPanel showPanelInView:self.view
                                            type:MKInfoPanelTypeError
                                           title:@"Image upload failed"
                                        subtitle:@"Imgur may be down for maintenance or overloaded."
                                       hideAfter:4];
                }
                [SVProgressHUD dismiss];
            }];
        }
        else
        {
            [SVProgressHUD showWithStatus:@"Posting..." maskType:SVProgressHUDMaskTypeBlack];
            [self internalPerformADNPost];
        }
    }
}

- (IBAction)photoAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take photo", @"Choose from library", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Helpers

- (CGRect)frameForSuggestionButtonAtIndex:(NSUInteger)index
{
    static CGFloat margin = 5.0f;
    ReferencedEntity *suggestion = currentSuggestions[index];
    NSString *title = [NSString stringWithFormat:@"%@%@", [suggestion.type intValue] == ANReferencedEntityTypeUsername ? @"@" : @"#", suggestion.name];
    CGSize stringSize = [title sizeWithFont:[UIFont systemFontOfSize:14]];
    CGRect lastButtonFrame = CGRectZero;
    if(index > 0)
        lastButtonFrame = [self frameForSuggestionButtonAtIndex:index - 1];
    CGRect frame = CGRectMake(lastButtonFrame.origin.x + lastButtonFrame.size.width + margin, margin, stringSize.width + margin, stringSize.height + margin);
    return frame;
}

- (UIButton *)buttonForSuggestionAtIndex:(NSUInteger)index
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = [self frameForSuggestionButtonAtIndex:index];
    button.tag = index;
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    button.titleLabel.shadowColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    button.titleLabel.shadowOffset = CGSizeMake(0, 1);

    ReferencedEntity *suggestion = currentSuggestions[index];
    NSString *title = [NSString stringWithFormat:@"%@%@", [suggestion.type intValue] == ANReferencedEntityTypeUsername ? @"@" : @"#", suggestion.name];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(suggestionAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

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
    NSRange inputRange = [postTextView selectedRange];
    NSMutableString *text = [postTextView.text mutableCopy];
    [text insertString:@"#" atIndex:inputRange.location];
    postTextView.text = text;
    inputRange.location += 1;
    inputRange.length = 0;
    [postTextView setSelectedRange:inputRange];
    currentCapture = [@"#" mutableCopy];
    currentCaptureType = ANReferencedEntityTypeHashtag;
    
    if([currentSuggestions count] > 0)
    {
        [UIView animateWithDuration:0.35f animations:^{
            CGRect frame = self.suggestionView.frame;
            frame.origin.y = 0;
            self.suggestionView.frame = frame;
        }];
    }
}

- (IBAction)mentionAction:(id)sender
{
    NSRange inputRange = [postTextView selectedRange];
    NSMutableString *text = [postTextView.text mutableCopy];
    [text insertString:@"@" atIndex:inputRange.location];
    postTextView.text = text;
    currentCapture = [@"@" mutableCopy];
    currentCaptureType = ANReferencedEntityTypeUsername;

    if([currentSuggestions count] > 0)
    {
        [UIView animateWithDuration:0.35f animations:^{
            CGRect frame = self.suggestionView.frame;
            frame.origin.y = 0;
            self.suggestionView.frame = frame;
        }];
    }
}

- (IBAction)clearPhotoAction:(id)sender
{
}

- (void)suggestionAction:(UIButton *)button
{
    NSRange inputRange = [postTextView selectedRange];
    NSMutableString *text = [postTextView.text mutableCopy];
    ReferencedEntity *suggestion = currentSuggestions[button.tag];
    NSString *title = [NSString stringWithFormat:@"%@%@", [suggestion.type intValue] == ANReferencedEntityTypeUsername ? @"@" : @"#", suggestion.name];

    if(currentCaptureRange.location != NSNotFound && inputRange.length > 0)
    {
        [text replaceCharactersInRange:inputRange withString:title];
    }
    else if(currentCaptureRange.location != NSNotFound && inputRange.length == 0)
    {
        [text replaceCharactersInRange:NSMakeRange(inputRange.location - [currentCapture length], [currentCapture length]) withString:@""];
        [text replaceCharactersInRange:currentCaptureRange withString:title];
    }
    else
    {
        NSString *stringToInsert = [title stringByReplacingOccurrencesOfString:currentCapture withString:@""];
        [text insertString:stringToInsert atIndex:inputRange.location];
    }
    postTextView.text = text;
    currentCapture = nil;

    [UIView animateWithDuration:0.35f animations:^{
        CGRect frame = self.suggestionView.frame;
        frame.origin.y = -frame.size.height;
        self.suggestionView.frame = frame;
    }];
}

#pragma mark - Action sheet delegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    
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
    if (!postImage)
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

#pragma mark - Textview delegate

- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    NSString* firstCharacter = nil;
    if(range.length == 0)
        firstCharacter = text;

    if([currentCapture length] == 0)
        currentCapture = nil;

    if(currentCapture == nil && ([firstCharacter isEqualToString:@"@"] || [firstCharacter isEqualToString:@"#"]))
    {
        // Started typing a username
        currentCapture = [NSMutableString string];
        currentCaptureType = [firstCharacter isEqualToString:@"@"] ? ANReferencedEntityTypeUsername : ANReferencedEntityTypeHashtag;
        if(range.length > 0)
            currentCapture = nil;
        else
        {
            currentCaptureRange = range;
            [currentCapture appendString:text];
        }
    }
    else if(currentCapture && [firstCharacter isEqualToString:@" "])
    {
        // Finished typing
        ReferencedEntity* re = [ReferencedEntity referencedEntityWithType:currentCaptureType name:[currentCapture substringFromIndex:1]];
        NSError* error = nil;
        [re save:&error successCallback:^{
            currentCapture = nil;
            currentCaptureRange = NSMakeRange(NSNotFound, 0);
        }];

        [UIView animateWithDuration:0.35f animations:^{
            CGRect frame = self.suggestionView.frame;
            frame.origin.y = -frame.size.height;
            self.suggestionView.frame = frame;
        }];
    }
    else if(currentCapture)
    {
        // Normal typing when a capture has started, but before it has finished.
        if(range.length > 0)
        {
            NSRange deletionRange = (NSRange){.location = [currentCapture length] - range.length, .length = range.length };
            [currentCapture deleteCharactersInRange:deletionRange];

            if([currentCapture isEqualToString:@""])
            {
                [UIView animateWithDuration:0.35f animations:^{
                    CGRect frame = self.suggestionView.frame;
                    frame.origin.y = -frame.size.height;
                    self.suggestionView.frame = frame;
                }];
            }
        }
        else
            [currentCapture appendString:text];

        if([currentCapture length] > 0)
        {
            NSString* sanitizedString = [currentCapture substringFromIndex:1];

            [[self.suggestionView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
            switch(currentCaptureType)
            {
                case ANReferencedEntityTypeUsername:
                    currentSuggestions = [[ANDataStoreController sharedController] usernamesForString:sanitizedString];
                    break;
                case ANReferencedEntityTypeHashtag:
                    currentSuggestions = [[ANDataStoreController sharedController] hashtagsForString:sanitizedString];
                    break;
            }

            CGRect lastFrame = CGRectZero;
            if([currentSuggestions count] > 0)
                lastFrame = [self frameForSuggestionButtonAtIndex:[currentSuggestions count] - 1];
            CGFloat width = CGRectGetMaxX(lastFrame);
            self.suggestionView.contentSize = CGSizeMake(width, CGRectGetHeight(self.suggestionView.bounds));
            for(NSInteger i = 0; i < [currentSuggestions count]; i++)
            {
                UIButton *button = [self buttonForSuggestionAtIndex:i];
                [self.suggestionView addSubview:button];
            }

            // Only show the suggestion view if we have suggestions.
            if([currentSuggestions count] > 0)
            {
                [UIView animateWithDuration:0.35f animations:^{
                    CGRect frame = self.suggestionView.frame;
                    frame.origin.y = 0;
                    self.suggestionView.frame = frame;
                }];
            }
        }
    }

    return YES;
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


- (void)viewDidUnload
{
    postImageButton = nil;
    self.suggestionView = nil;
    [super viewDidUnload];
}

@end
