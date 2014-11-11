//
//  Appointment.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Appointment.h"

@implementation Appointment

@dynamic clinic;
@dynamic description;
@dynamic date;
@dynamic status;
@dynamic patient;
@dynamic doctor;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Appointment";
}

- (void) update: (NSString *) status
{
    [self setObject:status forKey:@"status"];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Status saved...");
    }];
}

+ (void) save: (Appointment *) appointment {
    if (appointment.doctor != nil && appointment.patient != nil && appointment.clinic != nil)
    {
        [appointment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Appointment saved.");
        }];
    } else
    {
        NSLog(@"Appointment is invalid.");
    }
}

@end
