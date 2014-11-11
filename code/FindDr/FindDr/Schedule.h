//
//  Schedule.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>
#import "Clinic.h"

@interface Schedule : PFObject <PFSubclassing>

@property NSArray *monday;
@property NSArray *tuesday;
@property NSArray *wednesday;
@property NSArray *thursday;
@property NSArray *friday;
@property NSArray *saturday;
@property NSArray *sunday;
@property Clinic *clinic;

+ (void)getScheduleByClinic: (Clinic *) clinic sched: (void (^)(Schedule *schedule))complete;

+ (void) save: (Schedule *) schedule;

@end
