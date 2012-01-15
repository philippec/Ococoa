//
//  OCAppDelegate.m
//  Ococoa
//
//  Created by Philippe Casgrain on 11-12-17.
//  Copyright (c) 2011 Philippe Casgrain. All rights reserved.
//

#import "OCAppDelegate.h"

#import "OCViewController.h"
#import "OCPrivateInfo.h"
#import "OCDoorbell.h"
#import "Reachability.h"

@implementation OCAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize doorbell = _doorbell;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.viewController = [[OCViewController alloc] initWithNibName:@"OCViewController_iPhone" bundle:nil];
    }
    else
    {
        self.viewController = [[OCViewController alloc] initWithNibName:@"OCViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    self.doorbell = [[OCDoorbell alloc] init];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(ringDoorbell:) forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Ring Doorbell" forState:UIControlStateNormal];
    button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [self.viewController.view addSubview:button];

    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"My token is: %@", deviceToken);

    Reachability *r = [Reachability reachabilityWithHostName:@"https://go.urbanairship.com/"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if (internetStatus == NotReachable)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status" 
                                                        message:@"Sorry, the network does not appear to be available. Please try again later." 
                                                       delegate:nil 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else
    {
        // Convert the token to a hex string and make sure it's all caps
        NSMutableString *tokenString = [NSMutableString stringWithString:[[deviceToken description] uppercaseString]];
        [tokenString replaceOccurrencesOfString:@"<" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
        [tokenString replaceOccurrencesOfString:@">" withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];
        [tokenString replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, tokenString.length)];

        // Create the NSURL for the request
        NSString *urlFormat = @"https://go.urbanairship.com/api/device_tokens/%@";
        NSURL *registrationURL = [NSURL URLWithString:[NSString stringWithFormat:urlFormat, tokenString]];

        // Create the registration request
        NSMutableURLRequest *registrationRequest = [[NSMutableURLRequest alloc] initWithURL:registrationURL];
        [registrationRequest setHTTPMethod:@"PUT"];

        // And fire it off
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:registrationRequest delegate:self];
        [connection start];
    }
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", [error description]);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // Check for previous failures
    if ([challenge previousFailureCount] > 0)
    {
        // We've already tried - something is wrong with our credentials
        NSLog(@"Urban Airship credentials invalid");
        return;
    }

    // Send our Urban Airship credentials
    NSURLCredential *airshipCredentials = [NSURLCredential credentialWithUser:kUrbanAirshipAppKey
                                                                     password:kUrbanAirshipAppSecret
                                                                  persistence:NSURLCredentialPersistenceNone];
    [[challenge sender] useCredential:airshipCredentials forAuthenticationChallenge:challenge];  
    NSLog(@"Urban Airship credentials sent");
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Doorbell rang" message:[aps valueForKey:@"alert"] delegate:nil cancelButtonTitle:@"Done" otherButtonTitles:nil];
    [alert show];
    for (id key in userInfo)
    {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark IBActions

- (IBAction)ringDoorbell:(id)sender
{
    [self.doorbell ring];
}

@end
