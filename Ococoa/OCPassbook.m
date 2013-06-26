//
//  OCPassbook.m
//  Ococoa
//
//  Created by Philippe Casgrain on 2013-06-24.
//  Copyright (c) 2013 Philippe Casgrain. All rights reserved.
//

#import "OCPassbook.h"

@interface OCPassbook()
@property (assign) BOOL passbookAvailableInternal;
@end

@implementation OCPassbook

- (id)init
{
    if (self = [super init])
    {
        self.passbookAvailableInternal = [PKPass class] != nil;
        self.passbookAvailable = self.passbookAvailableInternal;
    }

    return self;
}

- (void)dealloc
{
    self.pass = nil;
    self.alertView = nil;
}

- (BOOL)passbookAvailable
{
    if (self.passbookAvailableInternal)
    {

    }
    else
    {
        [self.alertView show];
    }
    return self.passbookAvailableInternal;
}

- (void)setPassbookAvailable:(BOOL)passbookAvailable
{
    if (self.passbookAvailableInternal)
    {
        self.pass = [[PKPass alloc] initWithData:[NSData data] error:nil];
    }
    else
    {
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                    message:NSLocalizedString(@"Passbook requires iOS 6 or later.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    }
}

@end
