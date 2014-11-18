//
//  Search.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/14/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>
#import "Doctor.h"

@interface Search : NSObject

- (void) search: (NSString *)searchString;

- (void) loadClinics: (Doctor *)doc results: (void(^)(NSArray *clinics))complete ;

- (void) getDoctorsByName: (NSString *)name apps:(void (^)(NSArray *doctors))complete;

- (void) getDoctorsByClinicId: (NSString *)id apps:(void (^)(NSArray *doctors))complete;

@end
