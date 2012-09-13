//
//  OCDoorbellTests.m
//  Ococoa
//
//  Created by Philippe on 2012-09-08.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
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
    STAssertNotNil(self.doorBell.alertView, @"");
}

- (void)testMock
{
    id mock = [OCMockObject mockForClass:[NSDate class]];

    NSTimeInterval t = 20.0;
    [[[mock stub] andReturnValue:OCMOCK_VALUE(t)] timeIntervalSinceNow];
    STAssertEquals([mock timeIntervalSinceNow], 20.0, @"");
    [mock verify];
}

@end
