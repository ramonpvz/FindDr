//
//  Schedule.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Schedule.h"

@implementation Schedule

@dynamic monday;
@dynamic tuesday;
@dynamic wednesday;
@dynamic thursday;
@dynamic friday;
@dynamic saturday;
@dynamic sunday;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Schedule";
}

@end
