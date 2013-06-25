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
@class OCPassbook;

typedef enum
{
    OCStatus_None,
    OCStatus_basePageRequest,
    OCStatus_networkPageRequest,
    OCStatus_networkPageLoaded,
} OCPageLoadStatus;

@interface OCViewController : UIViewController <UIWebViewDelegate, CLLocationManagerDelegate>

@property (strong) OCDoorbell *doorbell;
@property (strong) OCPassbook *passbook;
@property (strong) UINavigationBar *navBar;
@property (strong) UIWebView *webView;
@property (strong) UIActivityIndicatorView *spinner;
@property (assign) OCPageLoadStatus pageLoadStatus;
@property (assign) BOOL debug;

- (void)startPageReloadTimer;
- (void)stopPageReloadTimer;
- (IBAction)ringDoorbell:(id)sender;

@end
