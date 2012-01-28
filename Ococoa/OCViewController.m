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

    NSString *strURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"Site URL"];
    
    CGRect baseRect = self.view.frame;
    CGRect webRect = baseRect;
    CGRect btnRect = baseRect;

    // Create a webview
    webRect.size.height -= kButtonSpace;
    self.webView = [[UIWebView alloc] initWithFrame:webRect];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strURL]]];
    self.webView.delegate = self;
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

#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
}

#pragma mark IBActions

- (IBAction)ringDoorbell:(id)sender
{
    [self.doorbell ring];
}

@end
