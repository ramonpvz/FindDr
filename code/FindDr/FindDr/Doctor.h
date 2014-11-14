//
//  User.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>
#import "Speciality.h"
#import "Clinic.h"
#import "Comment.h"

@interface Doctor : PFObject <PFSubclassing>

@property NSString *name;
@property NSString *lastName;
@property NSString *secondLastName;
@property NSString *title;
@property NSString *email;
@property NSString *licence;
@property NSString *gender;
@property NSDate *birthday;
@property NSString *phone;
@property PFRelation *specialities;
@property PFRelation *clinics;
@property PFFile *photo;
@property PFUser *user;
@property NSArray *comments;

+ (void) getDoctorByUser:(PFUser *)user doc:(void (^)(Doctor *doctor))complete;
- (void) getSpecialities:(void (^)(NSArray *specialities))complete;
- (void) getClinics:(void (^)(NSArray *clinics))complete;
- (void) getAppointmentsByStatus: (NSString *)status apps:(void (^)(NSArray *appointments))complete;
- (void) getAppointmentsByStatusAndDate: (NSDate *)date status: (NSString *)status apps:(void (^)(NSArray *appointments))complete;
- (void) getAppointments:(void (^)(NSArray *appointments))complete;
- (void) addSpeciality: (Speciality *) speciality;
- (void) addClinic: (Clinic *) clinic;
- (void) addComment: (Comment *) comment;

@end