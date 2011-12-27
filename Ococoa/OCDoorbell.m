//
//  OCDoorbell.m
//  Ococoa
//
//  Created by Philippe Casgrain on 11-12-27.
//  Copyright (c) 2011 Philippe Casgrain. All rights reserved.
//

#import "OCDoorbell.h"

@implementation OCDoorbell

-(void)ring
{
    NSLog(@"Ring ring!");    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    NSLog(@"Button: %d", buttonIndex);
    if (buttonIndex == 0)
        return;
}



@end
