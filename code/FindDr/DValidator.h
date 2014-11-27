//
//  Validate.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/11/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Schedule.h"

@interface DValidator : NSObject

+ (BOOL) validEmail : (NSString*) emailString;
+ (BOOL) validPassword : (NSString*) passString;
+ (NSString *) dateToString : (NSDate*) date;
+ (NSString *) dateToLabel : (NSDate*) date;
+ (NSDate *) stringToDate : (NSString*) date;
+ (NSDate*) roundDateMinuteToZero:(NSDate *)date ;
+ (NSDate *) formatDate : (NSString*) date;
+ (NSInteger) calculateAge : (NSDate*) birthday;
+ (BOOL) validateTimeSchedule: (NSDate*) date sched : (Schedule*) schedule;

@end