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

#import "ANAppDelegate.h"
#import "AuthViewController.h"
#import "MFSideMenuManager.h"
#import "ANSideMenuController.h"
#import "ANAPICall.h"
#import "RRDeviceMetadata.h"
#import "UIDevice+IdentifierAddition.h"
#import "RRConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "PocketAPI.h"
#import "MKInfoPanel.h"
#import "TestFlight.h"

@implementation ANAppDelegate


static ANAppDelegate *sharedInstance = nil;

+ (ANAppDelegate *)sharedInstance
{
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    sharedInstance = self;
    [NSURLCache setSharedURLCache:[self cacheInstance]];
    return self;
}

#pragma mark - Cache

- (NSURLCache *)cacheInstance
{
	NSURLCache *appCache;
	NSUInteger memoryCapacity = 1024 * 1024; // 1 megabytish.
	NSUInteger diskCapacity = 1024 * 1024 * 20; // 20 megabytish.
    
    // setup our cache to actually store shit to disk like a boss.
    
    // also, currently, no webservices are going to disk.  only image fetches.
    appCache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:@"Cache.db"];
    
	return appCache;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [TestFlight takeOff:@"c2a440bf3e4d6e2cb3a8267e89c71dc0_MTIwMjEwMjAxMi0wOC0xMCAyMTo0NjoyMC41MTQwODc"];
    [[PocketAPI sharedAPI] setAPIKey:kPocketAPIKey];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _sideMenuController = [[ANSideMenuController alloc] init];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[_sideMenuController.navigationArray objectAtIndex:0]];
    
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    // make sure to display the navigation controller before calling this
    [MFSideMenuManager configureWithNavigationController:navigationController
                                      sideMenuController:_sideMenuController];

    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
        NSLog(@"bacon");
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAuthenticate:) name:@"DidAuthenticate" object:nil];
    // if we don't have an access token or it's not a valid token, display auth.
    // probably should move back to calling Safari. <-- disagree, this looks fine. -- jedi
    if (![[ANAPICall sharedAppAPI] hasAccessToken] || ![[ANAPICall sharedAppAPI] isAccessTokenValid])
    {
        AuthViewController *authView = [[AuthViewController alloc] init];
        [self.window.rootViewController presentModalViewController:authView animated:YES];
    }
    
#ifdef DEBUG
    NSString *key = PMB_DEBUG_API_KEY;
    NSString *secret = PMB_DEBUG_API_SECRET;
#else
    NSString *key = PMB_API_KEY;
    NSString *secret = PMB_API_SECRET;
#endif
    pmbConnector = [[RRDefaultPlatformConnector alloc] initWithApiKey:key withApiSecret:secret];
    pmbConnector.delegate = self;
        
    [self _setupGlobalStyling];
    
    return YES;
}

// Use this method to set up any styles that are used app wide
- (void)_setupGlobalStyling
{
    // Set up navigation bar bg
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbarBg"] forBarMetrics:UIBarMetricsDefault];
    
    // Set up navigation title
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont:[UIFont fontWithName:@"Ubuntu-Medium" size:20.0f]}];
    
    // Set UIBarButton item bg
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"barbuttonBg"] stretchableImageWithLeftCapWidth:5.0f topCapHeight:0.0f] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont:[UIFont fontWithName:@"Ubuntu-Medium" size:12.0f]} forState:UIControlStateNormal];
    
    // Set up navigation bar rounded corners
    ((UINavigationController *)self.window.rootViewController).navigationBar.layer.mask = [self _navigationBarShapeLayer];
}

// https://[your registered redirect URI]/#access_token=[user access token]
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // Display text
    
    /*NSString *fragment = [url fragment];
    NSArray *components = [fragment componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for (NSString *component in components) {
        [parameters setObject:[[component componentsSeparatedByString:@"="] objectAtIndex:1] forKey:[[component componentsSeparatedByString:@"="] objectAtIndex:0]];
    }
    
    NSLog(@"%@",parameters);
    
    NSString *token = [parameters objectForKey:@"access_token"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"access_token"];
    [defaults synchronize];
    NSLog(@"access_token saved to defaults");
    */
    return YES;
}

- (void)didAuthenticate:(NSNotification *)notification
{
    if ([[ANAPICall sharedAppAPI] hasAccessToken] && [[ANAPICall sharedAppAPI] isAccessTokenValid]) {
        [self registerForRemoteNotifications];
    }
}

- (void)registerForRemoteNotifications
{
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound |
                                                                           UIRemoteNotificationTypeAlert |
                                                                           UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeBadge)];
}

- (void)registerDevice:(NSString *)deviceToken
{
    NSString *deviceId = [[UIDevice currentDevice] uniqueDeviceIdentifier];
    
    RRDeviceMetadata *metadata = [[RRDeviceMetadata alloc] initWithDeviceToken:deviceToken withDeviceId:deviceId];
    metadata.deviceName = [[UIDevice currentDevice] name];
    metadata.deviceModel = [[UIDevice currentDevice] model];
    metadata.systemName = [[UIDevice currentDevice] systemName];
    metadata.systemVersion = [[UIDevice currentDevice] systemVersion];
    metadata.tags = [NSDictionary dictionary];
    
    [pmbConnector asyncRegisterDevice:metadata];
    [pmbConnector asyncAssociateUser:[[ANAPICall sharedAppAPI] userID] withDeviceId:metadata.deviceId andAccessToken:[[ANAPICall sharedAppAPI] accessToken]];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)aDeviceToken
{
#ifdef DEBUG
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", [aDeviceToken description]);
#endif
    NSString *hexDeviceToken = [[aDeviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	NSString *deviceToken = [hexDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [self registerDevice:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error.localizedDescription);
#endif
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification");
    NSString *message = nil;
    
    id aps = [userInfo objectForKey:@"aps"];
    if ([aps isKindOfClass:[NSDictionary class]]) {
        message = (NSString *)[(NSDictionary *)aps objectForKey:@"alert"];
    }
    
    NSString *adnUsername = (NSString *)[userInfo objectForKey:@"adnUsername"];
    NSString *rawText = (NSString *)[userInfo objectForKey:@"rawText"];
    NSString *adnPostId = (NSString *)[userInfo objectForKey:@"adnPostId"]; // Can use this later for deep linking
    
    if (message) {
        [MKInfoPanel showPanelInView:self.window.rootViewController.view
                                type:MKInfoPanelTypeInfo
                               title:[NSString stringWithFormat:@"%@%@", @"@", adnUsername]
                            subtitle:rawText hideAfter:6.0f];
    }
}

- (void)didRegistrationFail:(RRDeviceMetadata *)_metadata withError:(NSError *)_error
{
#ifdef DEBUG
    // NSLog(@"didRegistrationFail:");
#endif
}

- (void)didRegistrationFinish:(RRDeviceMetadata *)_metadata
{
#ifdef DEBUG
    // NSLog(@"didRegistrationFinish:");
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSArray *controllers = self.sideMenuController.navigationArray;
    [controllers makeObjectsPerformSelector:@selector(refresh)];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    if ([[ANAPICall sharedAppAPI] hasAccessToken] && [[ANAPICall sharedAppAPI] isAccessTokenValid]) {
        [self registerForRemoteNotifications];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (CAShapeLayer *)_navigationBarShapeLayer
{
    CGFloat minx = 0.0f, midx = CGRectGetWidth(self.window.frame)/2.0f, maxx = CGRectGetWidth(self.window.frame);
    CGFloat miny = 0.0f, maxy = 60.0f;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, minx, maxy);
    CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, 2.0f);
    CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, maxy, 2.0f);
    CGPathAddLineToPoint(path, NULL, maxx, maxy);
    
    // Close the path
    CGPathCloseSubpath(path);
    
    // Fill & stroke the path
    CAShapeLayer *newShapeLayer = [[CAShapeLayer alloc] init];
    newShapeLayer.path = path;
    newShapeLayer.fillColor = [[UIColor greenColor] colorWithAlphaComponent:1.f].CGColor;
    CFRelease(path);
    
    return newShapeLayer;
}

@end
