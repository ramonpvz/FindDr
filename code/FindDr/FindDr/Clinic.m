//
//  Clinic.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Clinic.h"

@implementation Clinic

@dynamic doctor;
@dynamic name;
@dynamic street;
@dynamic number;
@dynamic city;
@dynamic state;
@dynamic zipCode;
@dynamic latitude;
@dynamic longitude;
@dynamic schedule;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Clinic";
}

@end
