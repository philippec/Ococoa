//
//  OCViewController.m
//  Ococoa
//
//  Created by Philippe Casgrain on 11-12-17.
//  Copyright (c) 2011 Philippe Casgrain. All rights reserved.
//

#import "OCViewController.h"
#import "OCDoorbell.h"

@implementation OCViewController

@synthesize doorbell = _doorbell;
@synthesize webView = _webView;
@synthesize spinner = _spinner;
@synthesize pageLoadStatus = _pageLoadStatus;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    const CGFloat kButtonSpace = 60.;
    
    [super viewDidLoad];

    self.doorbell = [[OCDoorbell alloc] init];

    CGRect baseRect = self.view.frame;
    CGRect webRect = baseRect;
    CGRect btnRect = baseRect;

    // Create a webview
    webRect.size.height -= kButtonSpace;
    self.webView = [[UIWebView alloc] initWithFrame:webRect];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.webView];
    self.webView.delegate = self;
    // Load our basic web page
    self.pageLoadStatus = OCStatus_basePageRequest;
    NSString *content = [[NSBundle mainBundle] pathForResource:@"cocoaheads" ofType:@"html"];
    [self.webView loadHTMLString:[NSString stringWithContentsOfFile:content encoding:NSUTF8StringEncoding error:nil] baseURL:nil];

    // Overlay a progress spinner, to be disabled when page has loaded
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.webView addSubview:self.spinner];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.center = self.webView.center;
    [self.spinner startAnimating];

    // Create the "Ring" button
    btnRect.size.height = 37.;
    btnRect.size.width = 123.;
    btnRect.origin.x = webRect.origin.x + (webRect.size.width - btnRect.size.width) / 2.;
    btnRect.origin.y = webRect.origin.y + webRect.size.height + (kButtonSpace - btnRect.size.height) / 2.;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(ringDoorbell:) forControlEvents:UIControlEventTouchDown];
    [button setTitle:NSLocalizedString(@"Ring Doorbell", nil) forState:UIControlStateNormal];
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    button.frame = btnRect;
    [self.view addSubview:button];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
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

- (void)loadSimplifiedRequest:(NSString*)strURL
{
    @autoreleasepool
    {
        // Load web content
        NSString *webContent = [NSString stringWithContentsOfURL:[NSURL URLWithString:strURL] encoding:NSUTF8StringEncoding error:nil];
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
                    NSLog(@"Should not happen, something is broken on the website");
                    break;
                }
            }
        }
        
        if (openDivCount == closeDivCount)
        {
            scheduleContent = [webContent substringWithRange:actualRange];
        }
        
        // Load our subset of the content into our specially-formatted html
        NSString *path = [[NSBundle mainBundle] pathForResource:@"cocoaheads" ofType:@"html"];
        NSMutableString *html = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] mutableCopy];
        [html replaceOccurrencesOfString:@"<meeting_info/>" withString:scheduleContent options:NSCaseInsensitiveSearch range:NSMakeRange(0, [html length])];
        
        [self.webView loadHTMLString:html baseURL:nil];
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
            NSLog(@"OCStatus_basePageRequest");
            nextStatus = OCStatus_networkPageRequest;

            // Load the whole web page on iPad, or just a subset on iPhone
            NSString *strURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Site URL"];
            
            if ([[UIDevice currentDevice] userInterfaceIdiom]  == UIUserInterfaceIdiomPad)
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strURL]]];
            else
                [NSThread detachNewThreadSelector:@selector(loadSimplifiedRequest:) toTarget:self withObject:strURL];
            
            break;
        }

        case OCStatus_networkPageRequest:
        {
            NSLog(@"OCStatus_networkPageRequest");
            nextStatus = OCStatus_networkPageLoaded;
            [self.spinner stopAnimating];
            break;
        }

        case OCStatus_networkPageLoaded:
        {
            NSLog(@"OCStatus_networkPageLoaded");
            break;
        }

        default:
        {
            NSAssert(FALSE, @"should handle default case %d", self.pageLoadStatus);
            break;
        }
    }

    self.pageLoadStatus = nextStatus;
}

#pragma mark IBActions

- (IBAction)ringDoorbell:(id)sender
{
    [self.doorbell ring];
}

@end
