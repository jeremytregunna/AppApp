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

#import "AuthViewController.h"
#import "ANAPICall.h"
#import "SVProgressHUD.h"
#import "ANAppDelegate.h"

@implementation AuthViewController
@synthesize authWebView;

- (id)init
{
    self = [super initWithNibName:@"AuthViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //TODO: MOVE OUT OF HERE
    NSString *redirectURI = @"appapp://callmemaybe";
    
    NSString *scopes = @"stream write_post follow messages";
    NSString *authURLstring = [NSString stringWithFormat:@"https://alpha.app.net/oauth/authenticate?client_id=%@&response_type=token&redirect_uri=%@&scope=%@&adnview=appstore", kANAPIClientID, redirectURI, scopes];
    NSURL *authURL = [NSURL URLWithString:[authURLstring stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:authURL];
    
    [authWebView loadRequest:requestObj];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSArray *components = [[request URL].absoluteString  componentsSeparatedByString:@"#"];
    
    if([components count]) {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        for (NSString *component in components) {
            
            if([[component componentsSeparatedByString:@"="] count] > 1) {
            [parameters setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
            }
        }
        
        if([parameters objectForKey:@"access_token"])
        {
            NSString *token = [parameters objectForKey:@"access_token"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:token forKey:@"access_token"];
            [defaults synchronize];
            
            [SVProgressHUD showWithStatus:@"Getting user information"];
            
            [[ANAPICall sharedAppAPI] getCurrentUser:^(id dataObject, NSError *error) {
                SDLog(@"currentUser = %@", dataObject);
                
                // all we need right now is userID, but there may be more stuff later.
                
                NSString *userID = [(NSDictionary *)dataObject objectForKey:@"id"];
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:userID forKey:@"userID"];
                [defaults synchronize];
                                
                [self dismissAuthenticationViewController:nil];
                [SVProgressHUD dismiss];
                NSArray *controllers = [ANAppDelegate sharedInstance].sideMenuController.navigationArray;
                [controllers makeObjectsPerformSelector:@selector(refresh)];
            }];
        }
    }

    return YES;
}

-(IBAction)dismissAuthenticationViewController:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
