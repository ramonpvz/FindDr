//
//  Login.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/7/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Login.h"

@implementation Login

- (void) signUp {
    
    PFUser *newUser = [PFUser user];
    
    newUser.username = @"Ramon";
    newUser.password = @"test123";
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else
        {
            NSLog(@"User saved...");
        }
    }];

}

- (void) logOut {
    
    [PFUser logOut];

}

- (PFUser *) currentUser {

    return [PFUser currentUser];

}

@end
