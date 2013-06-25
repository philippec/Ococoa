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
    STAssertFalse([self.passbook passbookAvailable], @"");
}

@end
