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
#import "Result.h"

@implementation Search


- (void) search: (NSString *)searchString results: (void(^)(NSArray *results))complete
{
    
    NSMutableArray *_results = [NSMutableArray array];
    
    PFQuery *specialityQuery = [Speciality query];
    
    NSString *criteria = [NSString stringWithFormat:@".*%@.*", searchString];
    
    [specialityQuery whereKey:@"name" matchesRegex:criteria];
    
    [specialityQuery findObjectsInBackgroundWithBlock:^(NSArray *specialitiesResult, NSError *error) {
        
        if(specialitiesResult == nil || [specialitiesResult count] == 0)
        {
            
            //---- SEARCHING BY DOCTOR NAME -----//
            
            PFQuery *doctorQuery = [Doctor query];
            
            [doctorQuery whereKey:@"name" matchesRegex:criteria];
            
            [doctorQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                for (Doctor *doc in objects) {
                    
                    Result *result = [[Result alloc] init];
                    
                    result.doctor = doc;
                    
                    [doc getClinics:^(NSArray *clinics) {
                        
                        NSMutableArray *clinicsList = [NSMutableArray array];

                        for (Clinic *clinic in clinics) {
                            
                            NSLog(@"Doctor %@ has  %@ speciality(ies) in the clinic: %@", doc.name, clinic.specialities,clinic.name);

                            [clinicsList addObject:clinic];

                        }

                        result.clinics = [NSArray arrayWithArray:clinicsList];

                        [_results addObject:result];
                        
                        complete(_results);

                    }];

                }
 
            }];
            
        }
        
        else
            
        {
            
            //---- SEARCHING BY SPECIALITY -----//
            
            PFQuery *doctorQry = [Doctor query];
            
            [doctorQry findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                for (Doctor *doc in objects) {
                    
                    [doc getClinics:^(NSArray *clinics) {

                        for (Clinic *clinic in clinics) {

                            for (Speciality *_speciality in clinic.specialities)

                            {
                                
                                for (Speciality *specFound in specialitiesResult)
                                    
                                {
                                    
                                    if ([_speciality.name isEqual:specFound.name])

                                    {
                                        
                                        NSLog(@"Doctor %@ has the speciality %@ in the clinic: %@", doc.name, _speciality.name,clinic.name);
                                        
                                        Result *result = [[Result alloc] init];
                                        
                                        result.doctor = doc;
                                        
                                        NSMutableArray *clinicsList = [NSMutableArray array];
                                        
                                        [clinicsList addObject:clinic];
                                        
                                        result.clinics = clinicsList;
                                        
                                        [_results addObject:result];
                                        
                                        complete(_results);

                                    }

                                }
                                
                            }
                            
                        }
                        
                    }];
                    
                }

            }];
            
        }
        
    }];

}

@end
