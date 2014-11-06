//
//  Speciality.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Speciality.h"

@implementation Speciality

@dynamic name;
@dynamic description;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Speciality";
}

@end