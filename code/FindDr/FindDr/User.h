//
//  User.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFObject <PFSubclassing>

@property NSString *name;
@property NSString *lastName;
@property NSString *secondLastName;
@property NSString *title;
@property NSString *email;
@property NSString *password;
@property NSString *licence;
@property PFFile *photo;
@property NSString *gender;
@property NSDate *birthday;
@property NSString *phone;
@property NSArray *specialities;

@end