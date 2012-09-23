//
//  OCViewController.h
//  Ococoa
//
//  Created by Philippe Casgrain on 11-12-17.
//  Copyright (c) 2011 Philippe Casgrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class OCDoorbell;

typedef enum
{
    OCStatus_None,
    OCStatus_basePageRequest,
    OCStatus_networkPageRequest,
    OCStatus_networkPageLoaded,
} OCPageLoadStatus;

@interface OCViewController : UIViewController <UIWebViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) OCDoorbell *doorbell;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (assign, nonatomic) OCPageLoadStatus pageLoadStatus;
@property (assign, nonatomic) BOOL debug;

- (void)startPageReloadTimer;
- (void)stopPageReloadTimer;
- (IBAction)ringDoorbell:(id)sender;

@end
