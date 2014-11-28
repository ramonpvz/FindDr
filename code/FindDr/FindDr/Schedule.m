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
@dynamic clinic;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Schedule";
}

+ (void)getScheduleByClinic: (Clinic *) clinic sched: (void (^)(Schedule *schedule))complete {
    PFQuery *scheduleQuery = [Schedule query];
    [scheduleQuery whereKey:@"clinic" equalTo:clinic];
    [scheduleQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            complete([objects objectAtIndex:0]);
        }
        else
        {
            complete(nil);
        }
    }];
}

+ (void) save: (Schedule *) schedule {
    if (schedule.clinic != nil) {
        [schedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Schedule saved.");
        }];
    }
    else
    {
        NSLog(@"Schedule is invalid.");
    }
}

@end
