//
//  Result.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/14/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>
#import "Doctor.h"

@interface Result : NSObject

@property Doctor *doctor;
@property NSArray *clinics;

@end
