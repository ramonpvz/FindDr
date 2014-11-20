//
//  Search.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/14/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Search.h"
#import <Parse/Parse.h>
#import "Speciality.h"
#import "Doctor.h"

@implementation Search

- (void) search: (NSString *)searchString {
    [self getDoctorsByName:searchString apps:^(NSArray *doctors) {
        if (doctors.count > 0) {
            for (Doctor *doc in doctors) {
                [self loadClinics:doc results:^(NSArray *clinics) {
                    for (Clinic *clinic in clinics) {
                        //Draw current clinic on map...
                        NSLog(@"Clinica: %@",clinic);
                    }
                }];
            }
        }
        else
        {
            NSLog(@"Doctor(s) not found by name: %@. Searching by speciality." , searchString);
            [self getClinicsBySpecialityName:searchString clinics:^(NSArray *clinics) {
                for (Clinic *clinic in clinics) {
                    [self getDoctorsByClinicId:clinic.objectId apps:^(NSArray *doctors) {
                        NSString *log = [NSString stringWithFormat:@"Clinic %@ has %lul doctors",clinic.name,doctors.count];
                        NSLog(@"%@",log);
                    }];
                }
            }];
        }
    }];
}

- (void) loadClinics: (Doctor *)doc results: (void(^)(NSArray *clinics))complete {
    [doc getClinics:^(NSArray *clinics) {
        complete (clinics);
    }];
}

- (void) getDoctorsByName: (NSString *)name apps:(void (^)(NSArray *doctors))complete
{
    NSString *criteria = [NSString stringWithFormat:@".*%@.*", name];
    PFQuery *doctorQuery = [Doctor query];
    [doctorQuery whereKey:@"name" matchesRegex:criteria];
    
    PFQuery *doctorApPatQuery = [Doctor query];
    [doctorApPatQuery whereKey:@"lastName" matchesRegex:criteria];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[doctorQuery, doctorApPatQuery]];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];
}

- (void) getDoctorsByClinicId: (NSString *)id apps:(void (^)(NSArray *doctors))complete {
    PFQuery *doctorQuery = [Doctor query];
    PFQuery *clinicQuery = [Clinic query];
    [clinicQuery whereKey:@"objectId" equalTo:id];
    [doctorQuery whereKey:@"clinics" matchesQuery:clinicQuery];
    [doctorQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];
}

- (void) getClinicsBySpecialityId: (NSString *)id clinics:(void (^)(NSArray *clinics))complete {
    PFQuery *clinicQuery = [Clinic query];
    PFQuery *specQuery = [Speciality query];
    [specQuery whereKey:@"name" equalTo:id];
    [clinicQuery whereKey:@"specialities" matchesQuery:specQuery];
    [clinicQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];
}

- (void) getClinicsBySpecialityName: (NSString *)name clinics:(void (^)(NSArray *clinics))complete {
    NSString *criteria = [NSString stringWithFormat:@".*%@.*", name];
    PFQuery *clinicQuery = [Clinic query];
    PFQuery *specQuery = [Speciality query];
    [specQuery whereKey:@"name" matchesRegex:criteria];
    [clinicQuery whereKey:@"specialities" matchesQuery:specQuery];
    [clinicQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];
}

@end
