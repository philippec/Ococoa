//
//  OCViewController.h
//  Ococoa
//
//  Created by Philippe Casgrain on 11-12-17.
//  Copyright (c) 2011 Philippe Casgrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OCDoorbell;

typedef enum
{
    OCStatus_None,
    OCStatus_basePageRequest,
    OCStatus_networkPageRequest,
    OCStatus_networkPageLoaded,
} OCPageLoadStatus;

@interface OCViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) OCDoorbell *doorbell;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (assign, nonatomic) OCPageLoadStatus pageLoadStatus;

- (IBAction)ringDoorbell:(id)sender;

@end
