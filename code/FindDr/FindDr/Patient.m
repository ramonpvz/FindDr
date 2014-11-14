//
//  Patient.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/6/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Patient.h"
#import "Appointment.h"
#import "DValidator.h"

@implementation Patient

@dynamic name;
@dynamic lastName;
@dynamic secondLastName;
@dynamic title;
@dynamic email;
@dynamic photo;
@dynamic gender;
@dynamic birthday;
@dynamic phone;
@dynamic user;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Patient";
}

+ (void) save: (Patient *) patient {
    if (patient.user != nil && patient.email != nil && [DValidator validEmail:patient.email]) {
        [patient saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Patient saved...");
        }];
    }
    else
    {
        NSLog(@"Patient is invalid.");
    }
}

- (void) getAppointments:(void (^)(NSArray *appointments))complete {
    PFQuery *appointmentsQuery = [Appointment query];
    [appointmentsQuery whereKey:@"patient" equalTo:self];
    [appointmentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    } ];
}

- (NSString *) getFullName {
    return [NSString stringWithFormat:@"%@ %@ %@", self.name, self.lastName, self.secondLastName];
}

- (void) loadImage: (void (^)(UIImage *image))complete {
    complete ([UIImage imageWithData:[NSData dataWithData:[self.photo getData]]]);
}

@end
