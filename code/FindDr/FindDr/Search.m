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
            NSString *criteria = [NSString stringWithFormat:@".*%@.*", searchString];
            PFQuery *specialityQuery = [Speciality query];
            [specialityQuery whereKey:@"name" matchesRegex:criteria];
            [specialityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (Speciality *_spec in objects) {
                    PFQuery *clinicsQry = [Clinic query];
                    [clinicsQry includeKey:@"specialities"];
                    [clinicsQry findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        for (Clinic *clinic in objects) {
                            NSPredicate *pred = [NSPredicate predicateWithFormat:@"objectId == %@",_spec.objectId];
                            NSArray *filteredSpecialities = [clinic.specialities filteredArrayUsingPredicate:pred];
                            if (filteredSpecialities != nil && filteredSpecialities.count > 0) {
                                
                                //Draw current clinic on map...
                                
                                [self getDoctorsByClinicId:clinic.objectId apps:^(NSArray *doctors) {
                                    NSLog(@"Doctors: %@",doctors);
                                }];
                                
                            }
                        }
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
    [doctorQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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

@end