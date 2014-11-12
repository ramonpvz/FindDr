//
//  Login.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/7/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Login.h"

@implementation Login

- (void) login:(NSDictionary *)credencials user:(void (^)(PFUser *pfUser))complete {
    NSString *usr = [credencials objectForKey:@"username"];
    NSString *pwd = [credencials objectForKey:@"password"];
    [PFUser logInWithUsernameInBackground:usr password:pwd block:^(PFUser *user, NSError *error) {
        complete(user);
    }];
}

- (NSString *) signUp: (NSString*)username pass: (NSString*) password {
    NSString *message = @"";
    if ([DValidator validEmail:username]) {
        if ([DValidator validPassword:password]) {
            PFUser *newUser = [PFUser user];
            newUser.username = username;
            newUser.password = password;
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                }
                else
                {
                    NSLog(@"User saved.");
                }
            }];
        }
        else
        {
            message = @"Password is incorrect; should be alphanumeric and not less than 6 characters.";
        }
    }
    else
    {
        message = @"User is incorrect, verify the e-mail format.";
    }
    return message;
}

- (void) logOut {

    [PFUser logOut];

}

- (PFUser *) getCurrentUser {

    return [PFUser currentUser];

}

@end
