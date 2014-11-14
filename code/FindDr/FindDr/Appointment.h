//
//  Appointment.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>
#import "Clinic.h"
#import "Patient.h"
#import "Doctor.h"

@interface Appointment : PFObject <PFSubclassing>

@property Clinic *clinic;
@property NSString *description;
@property NSDate *date;
@property NSString *status;
@property Patient *patient;
@property Doctor *doctor;

- (void) updateToStatus: (NSString *) status;

+ (void) save: (Appointment *) appointment;

@end