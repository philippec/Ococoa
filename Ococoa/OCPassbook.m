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
        self.passbookAvailableInternal = NO;
        if ([PKPass class] != nil)
        {
            self.passbookAvailableInternal = [PKPassLibrary isPassLibraryAvailable];
        }
        self.passbookAvailable = self.passbookAvailableInternal;
        self.alertView = [[UIAlertView alloc] initWithTitle:@"<don't translate>"
                                                    message:@"<don't translate"
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
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
    self.passbookAvailableInternal = passbookAvailable;
    if (!self.passbookAvailableInternal)
    {
        self.alertView.title = NSLocalizedString(@"Sorry", nil);
        self.alertView.message = NSLocalizedString(@"Passbook requires iOS 6 or later on iPhone or iPod Touch.", nil);
    }
}

- (void)presentPassWithData:(NSData *)passData fromViewController:(UIViewController *)viewController
{
    self.pass = [[PKPass alloc] initWithData:passData error:nil];
    PKPassLibrary *passLibrary = [[PKPassLibrary alloc] init];
    if ([passLibrary containsPass:self.pass])
    {
        self.alertView.title = NSLocalizedString(@"Thank you", nil);
        self.alertView.message = NSLocalizedString(@"This pass is already in your library.", nil);
        [self.alertView show];
    }
    else
    {
        PKAddPassesViewController *addViewController = [[PKAddPassesViewController alloc] initWithPass:self.pass];
        [viewController presentViewController:addViewController animated:YES completion:^{
            DebugLog(@"PKAddPassesViewController completion");
        }];
    }
}

@end
