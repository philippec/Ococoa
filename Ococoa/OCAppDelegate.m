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

@implementation OCAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

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

    // Let the device know we want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    DebugLog(@"My token is: %@", deviceToken);

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

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    DebugLog(@"Failed to get token, error: %@", [error description]);
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // Check for previous failures
    if ([challenge previousFailureCount] > 0)
    {
        // We've already tried - something is wrong with our credentials
        DebugLog(@"Urban Airship credentials invalid");
        return;
    }

    // Send our Urban Airship credentials
    NSURLCredential *airshipCredentials = [NSURLCredential credentialWithUser:kUrbanAirshipAppKey
                                                                     password:kUrbanAirshipAppSecret
                                                                  persistence:NSURLCredentialPersistenceNone];
    [[challenge sender] useCredential:airshipCredentials forAuthenticationChallenge:challenge];  
    DebugLog(@"Urban Airship credentials sent");
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSNumber *job = [userInfo valueForKey:@"job"];
    switch ([job intValue])
    {
        case 1:
        {
            // Schedule update
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Schedule update", nil) message:[aps valueForKey:@"alert"] delegate:nil cancelButtonTitle:NSLocalizedString(@"Done", nil) otherButtonTitles:nil];
            [alert show];
            [self.viewController startPageReloadTimer];
            break;
        }

        default:
        {
            // Doorbell
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Doorbell rang", nil) message:[aps valueForKey:@"alert"] delegate:nil cancelButtonTitle:NSLocalizedString(@"Done", nil) otherButtonTitles:nil];
            [alert show];
            break;
        }
    }

    for (id key in userInfo)
    {
        DebugLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    [self.viewController stopPageReloadTimer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [self.viewController stopPageReloadTimer];
    // Make sure we're not showing a badge icon
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [self.viewController startPageReloadTimer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [self.viewController startPageReloadTimer];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [self.viewController stopPageReloadTimer];
}

@end
