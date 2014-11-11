//
//  Ranking.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Ranking.h"
#import "Doctor.h"

@implementation Ranking

@dynamic patient;
@dynamic doctor;
@dynamic ranking;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Ranking";
}

+ (void) save: (Ranking *) ranking {
    if (ranking.patient != nil && ranking.doctor != nil && ranking.description != nil) {
        [ranking saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Ranking is saved.");
        }];
    }
    else
    {
        NSLog(@"Ranking is invalid.");
    }
}

@end