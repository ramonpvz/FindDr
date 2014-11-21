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

- (void) updateToStatus: (NSString *) status result:(void (^)(NSNumber *result))complete
{
    [self setObject:status forKey:@"status"];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error) {
            complete([NSNumber numberWithInt:1]);
        } else {
            NSLog(@"Error: %@",error);
        }
    }];
}

+ (void) save: (Appointment *) appointment result:(void (^) (BOOL error))conditionalBlock {
    if (appointment.doctor != nil && appointment.patient != nil && appointment.clinic != nil)
    {
        [appointment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                conditionalBlock(NO);
            }
            else
            {
                conditionalBlock(YES);
            }
        }];
    } else
    {
        NSLog(@"Appointment is invalid.");
    }
}

@end
