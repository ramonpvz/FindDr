//
//  Speciality.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Speciality.h"

@implementation Speciality

@dynamic name;
@dynamic description;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Speciality";
}

// --- Lists the specialities catalog --- //
+ (void)lisSpecialities:(void (^)(NSArray *specialities))complete {
    PFQuery *querySpecialities = [PFQuery queryWithClassName:@"Speciality"];
    [querySpecialities findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error)
        {
            NSLog(@"Error: %@" , error);
        }
        else {
            complete(objects);
        }
    }];
}

@end