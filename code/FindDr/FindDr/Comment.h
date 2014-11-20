//
//  Comment.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>
#import "Patient.h"
#import "Doctor.h"

@interface Comment : PFObject <PFSubclassing>

@property NSString *description;
@property Patient *patient;
@property Doctor *doctor;

+ (void) getCommentsByPatient:(Patient *)patient doc:(void (^)(NSArray *comments))complete;

+ (void) getCommentsByDoctor:(Doctor *)doctor doc:(void (^)(NSArray *comments))complete;

+ (void) addCommentToDoctor: (NSString *) doctor : (Doctor *) doc;

@end
