//
//  OCPassbook.h
//  Ococoa
//
//  Created by Philippe Casgrain on 2013-06-24.
//  Copyright (c) 2013 Philippe Casgrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PassKit/PassKit.h>

@interface OCPassbook : NSObject
@property (strong) PKPass *pass;
@property (strong) UIAlertView *alertView;
@property (assign) BOOL passbookAvailable;

- (void)presentPassWithData:(NSData *)passData fromViewController:(UIViewController *)viewController;

@end
