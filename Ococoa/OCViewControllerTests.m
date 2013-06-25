//
//  OCViewControllerTests.m
//  Ococoa
//
//  Created by Philippe Casgrain on 2013-06-25.
//  Copyright (c) 2013 Philippe Casgrain. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "OCViewController.h"
#import "OCPassbook.h"

@interface OCViewControllerTests : SenTestCase
@property (strong) OCViewController *controller;
@property (strong) id mockPassbook;
@end

@implementation OCViewControllerTests

- (void)setUp
{
    [super setUp];

    self.mockPassbook = [OCMockObject mockForClass:[OCPassbook class]];

    self.controller = [[OCViewController alloc] initWithNibName:nil bundle:[NSBundle bundleForClass:[OCViewController class]]];
    self.controller.passbook = self.mockPassbook;
}

- (void)tearDown
{
    self.mockPassbook = nil;
    self.controller = nil;

    [super tearDown];
}

- (void)testExists
{
    STAssertNoThrow(self.controller = [[OCViewController alloc] initWithNibName:nil bundle:[NSBundle bundleForClass:[OCViewController class]]], @"");
    STAssertNotNil(self.controller, @"");

    STAssertNotNil(self.controller.view, @"");
    STAssertNotNil(self.controller.doorbell, @"");
    STAssertNotNil(self.controller.passbook, @"");
}

- (void)testLoadAnyRequest
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://add-pass"]];
    BOOL result;
    STAssertNoThrow(result = [self.controller webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked], @"");
    STAssertTrue(result, @"");

    STAssertNoThrow([self.mockPassbook verify], @"");
}

- (void)testLoadAnyNavType
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"ococoa://add-pass"]];
    BOOL result;
    STAssertNoThrow(result = [self.controller webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther], @"");
    STAssertTrue(result, @"");

    STAssertNoThrow([self.mockPassbook verify], @"");
}

- (void)testTapLinkNoPassbook
{
    BOOL notAvailable = NO;
    [[[self.mockPassbook expect] andReturnValue:OCMOCK_VALUE(notAvailable)] passbookAvailable];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"ococoa://add-pass"]];
    BOOL result;
    STAssertNoThrow(result = [self.controller webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked], @"");
    STAssertFalse(result, @"");

    STAssertNoThrow([self.mockPassbook verify], @"");
}

@end
