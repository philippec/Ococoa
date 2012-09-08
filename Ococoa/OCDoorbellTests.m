//
//  OCDoorbellTests.m
//  Ococoa
//
//  Created by Philippe on 2012-09-08.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import "OCDoorbell.h"

@interface OCDoorbellTests : SenTestCase
{
    OCDoorbell *_doorBell;
}

@property (strong, nonatomic) OCDoorbell *doorBell;

@end

@implementation OCDoorbellTests

- (void)setUp
{
    [super setUp];

    self.doorBell = [[OCDoorbell alloc] init];
}

- (void)tearDown
{
    self.doorBell = nil;

    [super tearDown];
}

- (void)testExists
{
    STAssertNotNil(self.doorBell, @"");
}


@end
