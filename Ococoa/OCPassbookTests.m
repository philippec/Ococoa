//
//  OCPassbookTests.m
//  Ococoa
//
//  Created by Philippe Casgrain on 2013-06-24.
//  Copyright (c) 2013 Philippe Casgrain. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "OCPassbook.h"

@interface OCPassbookTests : SenTestCase
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
    STAssertNoThrow(self.passbook = [[OCPassbook alloc] init], @"");
    STAssertNotNil(self.passbook, @"");
    STAssertNotNil(self.passbook.alertView, @"");
}

- (void)testPassbookNotAvailable
{
    id mockAlert = [OCMockObject mockForClass:[UIAlertView class]];
    STAssertNoThrow(self.passbook.alertView = mockAlert, @"");

    [[mockAlert expect] setTitle:[OCMArg isNotNil]];
    [[mockAlert expect] setMessage:[OCMArg isNotNil]];

    STAssertNoThrow(self.passbook.passbookAvailable = NO, @"");
    STAssertNoThrow([mockAlert verify], @"");

    [[mockAlert expect] show];

    BOOL result;
    STAssertNoThrow(result = [self.passbook passbookAvailable], @"");
    STAssertFalse(result, @"");
    STAssertNoThrow([mockAlert verify], @"");
}

- (void)testPassbookAvailable
{
    id mockAlert = [OCMockObject mockForClass:[UIAlertView class]];
    STAssertNoThrow(self.passbook.alertView = mockAlert, @"");

    STAssertNoThrow(self.passbook.passbookAvailable = YES, @"");
    STAssertNoThrow([mockAlert verify], @"");

    BOOL result;
    STAssertNoThrow(result = [self.passbook passbookAvailable], @"");
    STAssertTrue(result, @"");
    STAssertNoThrow([mockAlert verify], @"");
}

@end
