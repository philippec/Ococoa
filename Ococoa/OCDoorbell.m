//
//  OCDoorbell.m
//  Ococoa
//
//  Created by Philippe Casgrain on 11-12-27.
//  Copyright (c) 2011 Philippe Casgrain. All rights reserved.
//

#import "OCDoorbell.h"
#import "OCPrivateInfo.h"

#define kDefaultName @"name"
#define kDefaultPass @"password"

@implementation OCDoorbell

-(void)ring
{
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultName];
    NSString *pass = [[NSUserDefaults standardUserDefaults] stringForKey:kDefaultPass];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Enter password" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ring", nil];

    if ([alertView respondsToSelector:@selector(setAlertViewStyle:)])
    {
        // Use new-style UIAlertView customization
        alertView.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        [alertView textFieldAtIndex:0].placeholder = @"Your name";
        [alertView textFieldAtIndex:0].text = name;
        [alertView textFieldAtIndex:1].text = pass;
    }
    else
    {
        // Old-style, for compatibility
        alertView.message = @"\n\n\n";
        _nameTF = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
        [_nameTF setBackgroundColor:[UIColor whiteColor]];
        _nameTF.placeholder = @"Your name";
        _nameTF.text = name;
        [alertView addSubview:_nameTF];
        [_nameTF becomeFirstResponder];
        _passwordTF = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 75.0, 260.0, 25.0)];
        [_passwordTF setBackgroundColor:[UIColor whiteColor]];
        _passwordTF.secureTextEntry = YES;
        _passwordTF.placeholder = @"Password";
        _passwordTF.text = pass;
        [alertView addSubview:_passwordTF];
    }

    [alertView show];    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView respondsToSelector:@selector(setAlertViewStyle:)])
    {
        _name = [alertView textFieldAtIndex:0].text;
        _password = [alertView textFieldAtIndex:1].text;
    }
    else
    {
        _name = _nameTF.text;
        _password = _passwordTF.text;
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    NSLog(@"Button: %d", buttonIndex);
    if (buttonIndex == 0)
        return;

    if ([_name length] > 0 && [_password length] > 0)
        [NSThread detachNewThreadSelector:@selector(callServer:) toTarget:self withObject:self];
}

- (void)callServer:(id)obj
{
    @autoreleasepool
    {
        NSLog(@"Ring ring!");
        NSString *msg = [NSString stringWithFormat:@"%@ is at the door", _name];
        NSString *key = [_password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kServerString, [msg stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], key]];
        NSError *err;
        NSString *result = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
        if ([result hasPrefix:@"200 OK"])
        {
            NSLog(@"Success: %@", result);
            [[NSUserDefaults standardUserDefaults] setValue:_name forKey:kDefaultName];
            [[NSUserDefaults standardUserDefaults] setValue:_password forKey:kDefaultPass];
        }
        else
        {
            NSLog(@"Failed: %@, error: %@", result, err);
        }
    }
}


@end
