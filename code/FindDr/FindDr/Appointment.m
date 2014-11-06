//
//  Appointment.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Appointment.h"

@implementation Appointment

@dynamic user;
@dynamic clinic;
@dynamic description;
@dynamic appDate;
@dynamic status;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Appointment";
}

@end
