//
//  OCViewControllerTests.m
//  Ococoa
//
//  Created by Philippe Casgrain on 2013-06-25.
//  Copyright (c) 2013 Philippe Casgrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OCViewController.h"
#import "OCPassbook.h"

@interface OCViewControllerTests : XCTestCase
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
    XCTAssertNoThrow(self.controller = [[OCViewController alloc] initWithNibName:nil bundle:[NSBundle bundleForClass:[OCViewController class]]], @"");
    XCTAssertNotNil(self.controller, @"");

    XCTAssertNotNil(self.controller.view, @"");
    XCTAssertNotNil(self.controller.passbook, @"");
}

- (void)testLoadAnyRequest
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://add-pass"]];
    BOOL result;
    XCTAssertNoThrow(result = [self.controller webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked], @"");
    XCTAssertTrue(result, @"");

    XCTAssertNoThrow([self.mockPassbook verify], @"");
}

- (void)testLoadAnyNavType
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"ococoa://add-pass"]];
    BOOL result;
    XCTAssertNoThrow(result = [self.controller webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther], @"");
    XCTAssertTrue(result, @"");

    XCTAssertNoThrow([self.mockPassbook verify], @"");
}

- (void)testTapLinkNoPassbook
{
    BOOL notAvailable = NO;
    [[[self.mockPassbook expect] andReturnValue:OCMOCK_VALUE(notAvailable)] passbookAvailable];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"ococoa://add-pass"]];
    BOOL result;
    XCTAssertNoThrow(result = [self.controller webView:nil shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked], @"");
    XCTAssertFalse(result, @"");

    XCTAssertNoThrow([self.mockPassbook verify], @"");
}

@end
