//
//  Validate.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/11/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface DValidator : NSObject

+ (BOOL) validEmail : (NSString*) emailString;
+ (BOOL) validPassword : (NSString*) passString;
+ (NSString *) dateToString : (NSDate*) date;
+ (NSDate *) stringToDate : (NSString*) date;
+ (NSDate*) roundDateMinuteToZero:(NSDate *)date ;

@end