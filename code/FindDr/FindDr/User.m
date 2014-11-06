//
//  User.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic name;
@dynamic lastName;
@dynamic secondLastName;
@dynamic title;
@dynamic email;
@dynamic password;
@dynamic licence;
@dynamic photo;
@dynamic gender;
@dynamic birthday;
@dynamic phone;
@dynamic specialities;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"User";
}

@end
