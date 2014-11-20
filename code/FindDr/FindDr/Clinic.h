//
//  Clinic.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>
#import "Speciality.h"

@interface Clinic : PFObject <PFSubclassing>

@property NSString *name;
@property NSString *street;
@property NSString *number;
@property NSString *city;
@property NSString *state;
@property NSString *zipCode;
@property NSString *latitude;
@property NSString *longitude;
@property PFRelation *specialities;
@property PFFile *photo;

+ (void) save: (Clinic *) clinic;

- (void) getSpecialities:(void (^)(NSArray *specialities))complete;

- (void) addSpeciality: (Speciality *) speciality;

- (void) removeSpeciality: (Speciality *) speciality;

- (NSString *) getFullAddress;

@end