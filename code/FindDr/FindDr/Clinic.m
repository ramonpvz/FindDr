//
//  Clinic.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Clinic.h"

@implementation Clinic

@dynamic name;
@dynamic street;
@dynamic number;
@dynamic city;
@dynamic state;
@dynamic zipCode;
@dynamic latitude;
@dynamic longitude;
@dynamic specialities;
@dynamic photo;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Clinic";
}

+ (void) save: (Clinic *) clinic {
    if (clinic.latitude != nil && clinic.longitude != nil)
    {
        [clinic saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                NSLog(@"Clinic is saved.");
            }
            else
            {
                NSLog(@"Error: %@",error);
            }
        }];
    }
    else
    {
        NSLog(@"Clinic is invalid.");
    }
}

- (void) addSpeciality: (Speciality *) speciality {
    PFRelation *specialityRelation = self.specialities;
    [specialityRelation addObject:speciality];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@",error);
        }
        else
        {
            NSLog(@"Speciality added.");
        }
    }];
}

- (void) removeSpeciality: (Speciality *) speciality {
    PFRelation *specialityRelation = self.specialities;
    [specialityRelation removeObject:speciality];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@",error);
        }
        else
        {
            NSLog(@"Speciality removed.");
        }
    }];
}

- (void)getSpecialities:(void (^)(NSArray *specialities))complete {
    PFQuery *specsQry = [self relationForKey:@"specialities"].query;
    [specsQry findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];
}

- (NSString *) getFullAddress {
    NSMutableString *address = [NSMutableString string];
    [address appendString:self.number == nil? @"n/a":self.number];
    [address appendString:@" "];
    [address appendString:self.street == nil? @"n/a":self.street];
    [address appendString:@" "];
    [address appendString:self.city == nil? @"n/a": self.city];
    [address appendString:@" "];
    [address appendString:self.state == nil? @"n/a": self.state];
    [address appendString:@" "];
    [address appendString:self.zipCode == nil? @"n/a": self.zipCode];
    return address;
}

@end
