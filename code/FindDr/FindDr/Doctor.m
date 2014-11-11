//
//  User.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Doctor.h"
#import "Appointment.h"
#import <Parse/Parse.h>

@implementation Doctor

@dynamic name;
@dynamic lastName;
@dynamic secondLastName;
@dynamic title;
@dynamic email;
@dynamic licence;
@dynamic photo;
@dynamic gender;
@dynamic birthday;
@dynamic phone;
@dynamic specialities;
@dynamic clinics;
@dynamic user;
@dynamic comments;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Doctor";
}

- (void)getSpecialities:(void (^)(NSArray *specialities))complete {
    PFQuery *specsQry = [self relationForKey:@"specialities"].query;
    [specsQry findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];
}

- (void)getClinics:(void (^)(NSArray *clinics))complete {
    PFQuery *clinicsQry = [self relationForKey:@"clinics"].query;
    [clinicsQry includeKey:@"specialities"];
    [clinicsQry findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];
}

- (void) getAppointments:(void (^)(NSArray *appointments))complete {
    PFQuery *appointmentsQuery = [Appointment query];
    [appointmentsQuery whereKey:@"doctor" equalTo:self];
    [appointmentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    } ];
}

- (void) addSpeciality: (Speciality *) speciality {
    PFRelation *specialityRelation = self.specialities;
    [specialityRelation addObject:speciality];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@",error);
        }
        else
        {
            NSLog(@"Speciality added.");
        }
    }];
}

- (void) addClinic: (Clinic *) clinic {
    PFRelation *clinicRelation = self.clinics;
    [clinicRelation addObject:clinic];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@",error);
        }
        else
        {
            NSLog(@"Clinic added.");
        }
    }];
}

- (void) addComment: (Comment *) comment {
    [self addObject:comment forKey:@"comments"];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Comment added");
    }];
}

@end
