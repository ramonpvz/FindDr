//
//  Login.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/7/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "DValidator.h"
#import "User.h"

@interface Login : NSObject

- (void) login:(NSDictionary *)credencials user:(void (^)(User *pfUser))complete;
- (void) newSignUp: (NSString*)username pass: (NSString*) password user:(void (^)(User *pfUser))complete;
- (NSString *) signUp: (NSString*)username pass: (NSString*) password;
- (void) logOut;
- (User *) getCurrentUser;

@end