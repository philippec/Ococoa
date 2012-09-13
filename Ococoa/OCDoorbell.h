//
//  OCDoorbell.h
//  Ococoa
//
//  Created by Philippe Casgrain on 11-12-27.
//  Copyright (c) 2011 Philippe Casgrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCDoorbell : NSObject <UIAlertViewDelegate>
{
@private
    __strong NSString *_name;
    __strong NSString *_password;
    __strong UITextField *_nameTF;
    __strong UITextField *_passwordTF;
}

@property (strong, nonatomic) UIAlertView *alertView;

-(void)ring;

@end
