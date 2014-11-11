//
//  Patient.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/6/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>

@interface Patient : PFObject <PFSubclassing>

@property NSString *name;
@property NSString *lastName;
@property NSString *secondLastName;
@property NSString *title;
@property NSString *email;
@property PFFile *photo;
@property NSString *gender;
@property NSDate *birthday;
@property NSString *phone;
@property PFUser *user;

- (void) getAppointments:(void (^)(NSArray *appointments))complete;

+ (void) save: (Patient *) patient;

@end
