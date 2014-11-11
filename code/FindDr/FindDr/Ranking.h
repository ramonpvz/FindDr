//
//  Ranking.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>
#import "Doctor.h"
#import "Patient.h"

@interface Ranking : PFObject <PFSubclassing>

@property Patient *patient;
@property Doctor *doctor;
@property NSNumber *ranking;

+ (void) save: (Ranking *) ranking;

@end