//
//  OCViewController.m
//  Ococoa
//
//  Created by Philippe Casgrain on 11-12-17.
//  Copyright (c) 2011 Philippe Casgrain. All rights reserved.
//

#import "OCViewController.h"
#import "OCDoorbell.h"
#import "OCPassbook.h"
#import "Reachability.h"

@interface OCViewController()
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSTimer *pageReloadTimer;
- (void)loadInitialWebPage:(id)sender;
- (void)loadBasicWebPage:(NSString*)pageContent withMeeting:(NSString*)meetingInfo withConnectivity:(NSString*)connInfo;
@end

@implementation OCViewController

@synthesize doorbell = _doorbell;
@synthesize navBar = _navBar;
@synthesize webView = _webView;
@synthesize spinner = _spinner;
@synthesize pageLoadStatus = _pageLoadStatus;
@synthesize debug = _debug;
@synthesize pageReloadTimer = _pageReloadTimer;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark Debug

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (IBAction)debugAction:(id)sender
{
    static NSUInteger debugCount = 1;
    NSString *str = @"http://ococoa-push.appspot.com/static/test.html";

    // alternate between real page and test page
    debugCount++;
    if (debugCount % 2)
        str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Site URL"];

    self.pageLoadStatus = OCStatus_networkPageRequest;
    NSURL *url = [NSURL URLWithString:str];
    [NSThread detachNewThreadSelector:@selector(loadSimplifiedRequest:) toTarget:self withObject:url];                
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventSubtypeMotionShake)
    {
        UINavigationItem *item = [self.navBar.items objectAtIndex:0];

        self.debug = !self.debug;
        if (self.debug)
        {
            item.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bug"]
                                                                      style:UIBarButtonItemStyleBordered
                                                                     target:self
                                                                     action:@selector(debugAction:)];
        }
        else
        {
            item.leftBarButtonItem = nil;
        }
    }
}


#pragma mark - View lifecycle

- (void)configureLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.purpose = NSLocalizedString(@"Ococoa uses your location to bypass the requirement to enter a username and password if you are near the front door.", nil);
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    NSLog(@"start updating location");
}

- (void)viewDidLoad
{
    const CGFloat kNavBarHeight = 44.;
    
    [super viewDidLoad];

    [self configureLocationManager];
    
    self.doorbell = [[OCDoorbell alloc] init];

    CGRect baseRect = self.view.frame;
    CGRect webRect = baseRect;
    CGRect navRect = baseRect;

    // Create the "Ring" button
    UIBarButtonItem *ringButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bell"]
                                                                   style:UIBarButtonItemStyleBordered                                                                  target:self
                                                                  action:@selector(ringDoorbell:)];
    // Add it to a nav item as the right-most button
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"OCocoa", nil)];
    item.rightBarButtonItem = ringButton;
    item.hidesBackButton = YES;

    // Create a NavigationBar on the top
    // We won't use it for navigation, but as a convenient place to put
    // the "Ring" button contained in the item
    navRect.size.height = kNavBarHeight;
    self.navBar = [[UINavigationBar alloc] initWithFrame:navRect];
    self.navBar.tintColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:1.0];
    self.navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.navBar pushNavigationItem:item animated:NO];
    [self.view addSubview:self.navBar];
    
    // Create a webview
    webRect.size.height -= kNavBarHeight;
    webRect.origin.y += kNavBarHeight;
    self.webView = [[UIWebView alloc] initWithFrame:webRect];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    [self startPageReloadTimer];

    // Overlay a progress spinner, to be disabled when page has loaded
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.webView addSubview:self.spinner];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.center = self.webView.center;
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.spinner startAnimating];

    self.passbook = [[OCPassbook alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self stopPageReloadTimer];
    self.webView = nil;
    
    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self becomeFirstResponder];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    }
    else
    {
        return YES;
    }
}

#pragma mark Utilities

- (void)loadInitialWebPage:(id)sender
{
    self.pageLoadStatus = OCStatus_basePageRequest;
    [self loadBasicWebPage:nil withMeeting:nil withConnectivity:nil];
}

- (void)loadBasicWebPage:(NSString*)pageContent withMeeting:(NSString*)meetingInfo withConnectivity:(NSString*)connInfo
{
    NSMutableString *html = [pageContent mutableCopy];
    if (html == nil)
    {
        // Load our basic web page, with meeting and connectivity info
        NSString *path = [[NSBundle mainBundle] pathForResource:@"cocoaheads" ofType:@"html"];   
        html = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] mutableCopy];
    }
    if (meetingInfo)
        [html replaceOccurrencesOfString:@"<meeting_info/>" withString:meetingInfo options:NSCaseInsensitiveSearch range:NSMakeRange(0, [html length])];
    if (connInfo)
        [html replaceOccurrencesOfString:@"<connection_info/>" withString:connInfo options:NSCaseInsensitiveSearch range:NSMakeRange(0, [html length])];
    
    @synchronized(self)
    {
        [self.webView loadHTMLString:html baseURL:nil];
    }
}


#pragma mark Simplified html view

- (NSUInteger)countOfString:(NSString*)searchString inRange:(NSRange)range forString:(NSString*)fullString
{
    NSUInteger count = 0;
    NSRange searchRange = range;
    while (searchRange.location != NSNotFound)
    {
        searchRange = [fullString rangeOfString:searchString options:NSCaseInsensitiveSearch range:searchRange];
        if (searchRange.length > 0)
        {
            searchRange.location += searchRange.length;
            searchRange.length = range.location + range.length - searchRange.location;
            count++; 
        }
    }
    return count;
}

- (NSString*) pageStyle
{
    NSString *result = nil;
    NSString *str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Style URL"];
    NSURL *url = [NSURL URLWithString:str];
    Reachability *r = [Reachability reachabilityWithHostName:[url host]];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if (internetStatus != NotReachable)
    {
        NSError *err;
        result = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        if (err)
        {
            DebugLog(@"Error {%@} downloading from {%@}", err, url);
            result = nil; // just to be sure
        }
    }

    return result;
}

- (void)loadSimplifiedRequest:(NSURL*)url
{
    @autoreleasepool
    {
        // Load web content
        NSError *err = nil;
        NSString *webContent = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        NSString *scheduleContent = nil;
        // Search for '<div id="right-content"'
        NSRange divRange = [webContent rangeOfString:@"<div id=\"right-content\"" options:NSCaseInsensitiveSearch];
        NSRange actualRange = divRange;
        // We have one 'open' div ("<div") and no 'close' div ('</div') so far
        NSUInteger openDivCount = 1;
        NSUInteger closeDivCount = 0;
        if (divRange.length > 0)
        {
            // Look for matching '</div>' to our opening '<div'.
            // We simply search for the next '</div' and check for any '<div' in between
            // Assuming they are properly balanced, we should be able to find our *own* closing div
            // by making sure the number of open divs matches the number of close divs.
            NSRange searchRange = NSMakeRange(divRange.location, [webContent length] - divRange.location);
            NSRange remainingRange = searchRange;
            actualRange = searchRange;
            while (openDivCount != closeDivCount)
            {
                NSRange endRange = [webContent rangeOfString:@"</div>" options:NSCaseInsensitiveSearch range:remainingRange];
                if (endRange.location != NSNotFound)
                {
                    // Adjust ranges to search for the next closing div
                    actualRange.length =  endRange.length + endRange.location - divRange.location;
                    remainingRange.location = endRange.location + endRange.length;
                    remainingRange.length = searchRange.length - actualRange.length;
                    openDivCount = [self countOfString:@"<div" inRange:actualRange forString:webContent];
                    closeDivCount = [self countOfString:@"</div" inRange:actualRange forString:webContent];
                }
                else
                {
                    DebugLog(@"Should not happen, something is broken on the website");
                    break;
                }
            }
        }
        if (err)
        {
            DebugLog(@"Error {%@} downloading from {%@}", err, url);
        }
        
        if (openDivCount == closeDivCount)
        {
            scheduleContent = [webContent substringWithRange:actualRange];
        }

        [self loadBasicWebPage:[self pageStyle] withMeeting:scheduleContent withConnectivity:nil];
    }
}

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    OCPageLoadStatus nextStatus = OCStatus_None;

    switch (self.pageLoadStatus)
    {
        case OCStatus_basePageRequest:
        {
            DebugLog(@"OCStatus_basePageRequest");
            nextStatus = OCStatus_networkPageRequest;

            // Load the whole web page on iPad, or just a subset on iPhone
            NSString *str = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Site URL"];
            NSURL *url = [NSURL URLWithString:str];
            Reachability *r = [Reachability reachabilityWithHostName:[url host]];
            NetworkStatus internetStatus = [r currentReachabilityStatus];
            if (internetStatus == NotReachable)
            {
                [self loadBasicWebPage:nil withMeeting:nil withConnectivity:NSLocalizedString(@"Network Unavailable", nil)];
                [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadInitialWebPage:) userInfo:nil repeats:NO];
            }
            else
            {
                if ([[UIDevice currentDevice] userInterfaceIdiom]  == UIUserInterfaceIdiomPad)
                    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
                else
                    [NSThread detachNewThreadSelector:@selector(loadSimplifiedRequest:) toTarget:self withObject:url];                
            }
            
            break;
        }

        case OCStatus_networkPageRequest:
        {
            DebugLog(@"OCStatus_networkPageRequest");
            nextStatus = OCStatus_networkPageLoaded;
            [self.spinner stopAnimating];
            break;
        }

        case OCStatus_networkPageLoaded:
        {
            DebugLog(@"OCStatus_networkPageLoaded");
            break;
        }

        default:
        {
            DebugLog(@"should handle default case %d", self.pageLoadStatus);
            break;
        }
    }

    self.pageLoadStatus = nextStatus;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType != UIWebViewNavigationTypeLinkClicked)
    {
        return YES;
    }

    // User tapped a link, check if we should handle it
    if (![request.URL.scheme isEqualToString:@"ococoa"])
    {
        return YES;
    }

    // Link is ours, decide what to do
    if ([request.URL.host isEqualToString:@"add-pass"])
    {
        if ([self.passbook passbookAvailable])
            [self addPassToPassbook];
    }

    return NO;
}

#pragma mark Page Reload timer

- (void)startPageReloadTimer
{
    [self stopPageReloadTimer];
    [self loadInitialWebPage:nil];
    self.pageReloadTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(startPageReloadTimer) userInfo:nil repeats:NO];
    DebugLog(@"Timer fired");
}

- (void)stopPageReloadTimer
{
    [self.pageReloadTimer invalidate];
    self.pageReloadTimer = nil;
    
}

#pragma mark IBActions

- (IBAction)ringDoorbell:(id)sender
{
    // send any location that we may have
    [self.doorbell ring:self.locationManager.location];
}

#pragma mark Passbook

- (void)addPassToPassbook
{
    
}

@end
