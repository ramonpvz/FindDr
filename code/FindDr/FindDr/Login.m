//
//  Login.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/7/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Login.h"
#import "User.h"

@implementation Login

- (void) login:(NSDictionary *)credencials user:(void (^)(User *pfUser))complete {
    NSString *usr = [credencials objectForKey:@"username"];
    NSString *pwd = [credencials objectForKey:@"password"];
    [User logInWithUsernameInBackground:usr password:pwd block:^(PFUser *user, NSError *error) {
        User *usr = (User *)[PFUser user];
        usr.profile = [user objectForKey:@"profile"];
        complete(usr);
    }];
}

- (void) signUp: (NSString*)username pass: (NSString*) password user:(void (^)(User *pfUser))complete {
    User *userError = [[User alloc] init];
    if ([DValidator validEmail:username]) {
        if ([DValidator validPassword:password]) {
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"username" equalTo:username];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count > 0) {
                    userError.message = [NSString  stringWithFormat:@"Sorry, the user %@ already exists.", username];
                    complete(userError);
                }
                else
                {
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
                            complete((User *)newUser);
                        }
                    }];
                }
            }];
        }
        else
        {
            userError.message = @"Password is incorrect; should be alphanumeric and not less than 6 characters.";
            complete(userError);
        }
    }
    else
    {
        userError.message = @"User is incorrect, verify the e-mail format.";
        complete(userError);
    }
}

- (void) logOut {

    [User logOut];

}

- (User *) getCurrentUser {

    return [User currentUser];

}

@end
