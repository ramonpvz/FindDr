//
//  Time.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Time.h"

@implementation Time

@dynamic time;
@dynamic active;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Time";
}

@end
