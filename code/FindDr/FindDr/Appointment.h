//
//  Appointment.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "Clinic.h"

@interface Appointment : PFObject <PFSubclassing>

@property User *user;
@property Clinic *clinic;
@property NSString *description;
@property NSDate *appDate;
@property NSString *status;
@property User *patient;

@end