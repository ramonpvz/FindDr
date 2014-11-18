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

//+ (void) getDoctorByUser:(PFUser *)user doc:(void (^)(Doctor *doctor))complete;

- (void) updateToStatus: (NSString *) status result:(void (^)(NSNumber *result))complete;;

+ (void) save: (Appointment *) appointment;

@end