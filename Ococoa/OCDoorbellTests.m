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

- (void)testRing
{
    id mockAlert = [OCMockObject mockForClass:[UIAlertView class]];

    STAssertNoThrow(self.doorBell.alertView = mockAlert, @"");

    // This will always return YES, so it cannot be mocked properly
    // see http://stackoverflow.com/questions/11098615/how-to-stub-respondstoselector-method
    //[[mockAlert expect] respondsToSelector:@selector(setAlertViewStyle:)];
    [[mockAlert expect] setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[mockAlert expect] textFieldAtIndex:0];
    [[mockAlert expect] textFieldAtIndex:0];
    [[mockAlert expect] textFieldAtIndex:1];
    [[mockAlert expect] show];

    STAssertNoThrow([self.doorBell ring], @"");

    [mockAlert verify];
}

@end
