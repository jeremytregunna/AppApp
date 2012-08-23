//
//  ANReadLaterAuthViewController.m
//  AppApp
//
//  Created by Jeremy Tregunna on 2012-08-22.
//  Copyright (c) 2012 Sneakyness. All rights reserved.
//

#import "ANReadLaterAuthViewController.h"
#import "PocketAPI.h"

@interface ANReadLaterAuthViewController ()
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UILabel *serviceNameLabel;
@property (nonatomic, weak) IBOutlet UITextField *usernameField;
@property (nonatomic, weak) IBOutlet UITextField *passwordField;
@end

@implementation ANReadLaterAuthViewController
{
    ANReadLaterType serviceType;
}

@synthesize serviceNameLabel = _serviceNameLabel;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;

- (id)initWithServiceType:(ANReadLaterType)type
{
    if((self = [super initWithNibName:@"ANReadLaterAuthViewController" bundle:nil]))
        serviceType = type;
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *backgroundPatternImage = [UIImage imageNamed:@"statusCellBackground"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundPatternImage];
    _serviceNameLabel.text = [ANReadLaterManager serviceNameForType:serviceType];
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if(textField == self.usernameField)
        [self.passwordField becomeFirstResponder];
    else
    {
        [textField resignFirstResponder];
        [self loginWithUsername:[_usernameField text] password:[_passwordField text]];
    }
    return YES;
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
{
    switch(serviceType)
    {
        case kANReadLaterTypePocket:
            [[PocketAPI sharedAPI] loginWithUsername:username password:password handler:^(PocketAPI *api, NSError *error) {
                if(error)
                {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Logging In", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", @"") otherButtonTitles:nil];
                    [alertView show];
                }
                else
                    [self dismissViewControllerAnimated:YES completion:^{
                        // Do something cool here, like show a success message
                    }];
            }];
    }
}

- (IBAction)tryLogin:(id)sender
{
    [self loginWithUsername:_usernameField.text password:_passwordField.text];
}

- (IBAction)cancelLogin:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Gesture recognition

- (void)stopEditing:(UITapGestureRecognizer*)recognizer
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

@end
