//
//  OCDoorbellTests.m
//  Ococoa
//
//  Created by Philippe on 2012-09-08.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OCDoorbell.h"

@interface OCDoorbellTests : XCTestCase
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
    XCTAssertNotNil(self.doorBell, @"");
    XCTAssertNotNil(self.doorBell.alertView, @"");
}

- (void)testRing
{
    id mockAlert = [OCMockObject mockForClass:[UIAlertView class]];

    XCTAssertNoThrow(self.doorBell.alertView = mockAlert, @"");

    // This will always return YES, so it cannot be mocked properly
    // see http://stackoverflow.com/questions/11098615/how-to-stub-respondstoselector-method
    //[[mockAlert expect] respondsToSelector:@selector(setAlertViewStyle:)];
    [[mockAlert expect] setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[mockAlert expect] textFieldAtIndex:0];
    [[mockAlert expect] textFieldAtIndex:0];
    [[mockAlert expect] textFieldAtIndex:1];
    [[mockAlert expect] show];

    XCTAssertNoThrow([self.doorBell ring:nil], @"");

    [mockAlert verify];
}

- (void)testRingAtFrontDoor
{
    id mockAlert = [OCMockObject mockForClass:[UIAlertView class]];

    XCTAssertNoThrow(self.doorBell.alertView = mockAlert, @"");

    CLLocation *inFrontOfCodeFactory = [[CLLocation alloc] initWithLatitude:45.420 longitude:-75.702];

    // This will always return YES, so it cannot be mocked properly
    // see http://stackoverflow.com/questions/11098615/how-to-stub-respondstoselector-method
    //[[mockAlert expect] respondsToSelector:@selector(setAlertViewStyle:)];
    [[mockAlert expect] setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[mockAlert expect] textFieldAtIndex:0];
    [[mockAlert expect] textFieldAtIndex:0];
    [[mockAlert expect] textFieldAtIndex:1];
    [[mockAlert expect] show];

    XCTAssertNoThrow([self.doorBell ring:inFrontOfCodeFactory], @"");

    [mockAlert verify];
}
@end
