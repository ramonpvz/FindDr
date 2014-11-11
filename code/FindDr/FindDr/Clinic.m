//
//  Clinic.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Clinic.h"

@implementation Clinic

@dynamic name;
@dynamic street;
@dynamic number;
@dynamic city;
@dynamic state;
@dynamic zipCode;
@dynamic latitude;
@dynamic longitude;
@dynamic specialities;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Clinic";
}

+ (void) save: (Clinic *) clinic {
    if (clinic.latitude != nil && clinic.longitude != nil)
    {
        [clinic saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                NSLog(@"Clinic is saved.");
            }
            else
            {
                NSLog(@"Error: %@",error);
            }
        }];
    }
    else
    {
        NSLog(@"Clinic is invalid.");
    }
}

@end
