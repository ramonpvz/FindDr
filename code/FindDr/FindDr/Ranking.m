//
//  Ranking.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Ranking.h"
#import "User.h"

@implementation Ranking

@dynamic user;
@dynamic doctor;
@dynamic ranking;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Ranking";
}

@end
