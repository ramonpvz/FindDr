//
//  Speciality.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>

@interface Speciality : PFObject <PFSubclassing>

@property NSString *name;
@property NSString *description;

+ (void)lisSpecialities:(void (^)(NSArray *specialities))complete;

@end