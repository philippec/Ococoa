//
//  OCPassbookTests.m
//  Ococoa
//
//  Created by Philippe Casgrain on 2013-06-24.
//  Copyright (c) 2013 Philippe Casgrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OCPassbook.h"

@interface OCPassbookTests : XCTestCase
@property (strong) OCPassbook *passbook;
@end

@implementation OCPassbookTests

- (void)setUp
{
    [super setUp];

    self.passbook = [[OCPassbook alloc] init];
}

- (void)tearDown
{
    self.passbook = nil;

    [super tearDown];
}

- (void)testExists
{
    XCTAssertNoThrow(self.passbook = [[OCPassbook alloc] init], @"");
    XCTAssertNotNil(self.passbook, @"");
    XCTAssertNotNil(self.passbook.alertView, @"");
}

- (void)testPassbookNotAvailable
{
    id mockAlert = [OCMockObject mockForClass:[UIAlertView class]];
    XCTAssertNoThrow(self.passbook.alertView = mockAlert, @"");

    [[mockAlert expect] setTitle:[OCMArg isNotNil]];
    [[mockAlert expect] setMessage:[OCMArg isNotNil]];

    XCTAssertNoThrow(self.passbook.passbookAvailable = NO, @"");
    XCTAssertNoThrow([mockAlert verify], @"");

    [[mockAlert expect] show];

    BOOL result;
    XCTAssertNoThrow(result = [self.passbook passbookAvailable], @"");
    XCTAssertFalse(result, @"");
    XCTAssertNoThrow([mockAlert verify], @"");
}

- (void)testPassbookAvailable
{
    id mockAlert = [OCMockObject mockForClass:[UIAlertView class]];
    XCTAssertNoThrow(self.passbook.alertView = mockAlert, @"");

    XCTAssertNoThrow(self.passbook.passbookAvailable = YES, @"");
    XCTAssertNoThrow([mockAlert verify], @"");

    BOOL result;
    XCTAssertNoThrow(result = [self.passbook passbookAvailable], @"");
    XCTAssertTrue(result, @"");
    XCTAssertNoThrow([mockAlert verify], @"");
}

@end
