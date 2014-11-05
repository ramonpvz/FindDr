
//
//  Day.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Day.h"

@implementation Day

@dynamic times;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Day";
}

@end
