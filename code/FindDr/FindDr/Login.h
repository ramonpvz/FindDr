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

@interface Login : NSObject

- (NSString *) signUp: (NSString*)username pass: (NSString*) password;
- (void) logOut;
- (PFUser *) getCurrentUser;

@end