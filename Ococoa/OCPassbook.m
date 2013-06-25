//
//  OCPassbook.m
//  Ococoa
//
//  Created by Philippe Casgrain on 2013-06-24.
//  Copyright (c) 2013 Philippe Casgrain. All rights reserved.
//

#import "OCPassbook.h"

@implementation OCPassbook

- (id)init
{
    if (self = [super init])
    {
        self.alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                    message:NSLocalizedString(@"Passbook requires iOS 6 or later.", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    }

    return self;
}

- (void)dealloc
{
    self.alertView = nil;
}

- (BOOL)passbookAvailable
{
    [self.alertView show];
    return NO;
}

@end
