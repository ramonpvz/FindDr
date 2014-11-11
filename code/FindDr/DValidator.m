//
//  Validate.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/11/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "DValidator.h"

@implementation DValidator

+ (BOOL) validEmail : (NSString*) emailString {
    if ([emailString length] == 0) {
        return NO;
    }
    else
    {
        NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
        if (regExMatches == 0) {
            return NO;
        }
        else
        {
            return YES;
        }
    }
}

+ (BOOL) validPassword : (NSString*) passString {
    if ([passString length] < 6 || [passString length] > 32)
    {
        return NO;
    }
    else
    {
        NSRange rang = [passString rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
        if(!rang.length) return NO;
        rang = [passString rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
        if (!rang.length) return NO;
        return YES;
    }
}

@end
