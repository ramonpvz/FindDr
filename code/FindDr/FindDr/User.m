//
//  User.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/13/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic message;
@dynamic profile;

+ (void) load
{
    [self registerSubclass];
}

//+ (NSString *) parseClassName {
//    return @"User";
//}

@end
