//
//  ViewController.m
//  FindDr
//
//  Created by eduardo milpas diaz on 11/4/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Clinic.h"
#import "Schedule.h"
#import "Day.h"
#import "Time.h"
#import "Ranking.h"
#import "Comment.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"licence = %@", @"G12345"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"User" predicate:predicate];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.userInfo);
        }
        else
        {
            User *doctor = [objects objectAtIndex:0];
            
            NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"email = %@", @"firstusr@gmail.com"];
            PFQuery *query2 = [PFQuery queryWithClassName:@"User" predicate:predicate2];
            [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                Ranking *ranking = [Ranking object];
//                ranking.user = [objects objectAtIndex:0];
//                ranking.doctor = doctor;
//                ranking.ranking = [NSNumber numberWithInt:5];
//                [ranking saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    NSLog(@"Ranking saved...");
//                }];
                
//                Comment *comment = [Comment object];
//                comment.user = [objects objectAtIndex:0];
//                comment.doctor = doctor;
//                comment.description = @"First parse comment";
//                [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                    NSLog(@"Comment saved...");
//                }];
            }];
            
            PFQuery *cliniquesQuery = [Clinic query];
            [cliniquesQuery whereKey:@"doctor" equalTo:doctor];
            [cliniquesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (int i = 0; i < objects.count; i++) {
                    Clinic *clin = [objects objectAtIndex:i];
                    Schedule *schedule = clin.schedule;
                    PFQuery *schedulesQuery = [Schedule query];
                    [schedulesQuery whereKey:@"objectId" equalTo:schedule.objectId];
                    [schedulesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        Schedule *schedule = [objects objectAtIndex:0];
                        if(schedule.monday != nil) {
                            PFQuery *mondayQuery = [Day query];
                            [mondayQuery whereKey:@"objectId" equalTo:schedule.monday.objectId];
                            [mondayQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                Day *monday = [objects objectAtIndex:0];
                                for (Time *time in monday.times) {
                                    PFQuery *timesQuery = [Time query];
                                    [timesQuery whereKey:@"objectId" equalTo:time.objectId];
                                    [timesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                        for (Time *_time in objects) {
                                            NSLog(@"Time: %@, Active: %d", _time.time, _time.active);
                                        }
                                    }];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];

}


- (IBAction)test:(id)sender {
    
    NSString *str =@"3/15/1981";
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *date = [formatter dateFromString:str];

    User *doctor = [User object];
    doctor.name = @"Jessica";
    doctor.lastName = @"Morelos";
    doctor.secondLastName = @"Perez";
    doctor.title = @"Sra.";
    doctor.email = @"jess@gmail.com";
    doctor.password = @"12345";
    doctor.licence = @"G12345";
    doctor.gender = @"M";
    doctor.birthday = date;
    doctor.phone = @"6767676767";
    
    // ------- Saving doctor ------- //
    [doctor saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Doctor saved...");
    }];
    // ------- Saving doctor ------- //
    
    NSMutableArray *mondayTimes = [[NSMutableArray alloc] init];
    NSMutableArray *fridayTimes = [[NSMutableArray alloc] init];
    
    Time *mTime8 = [[Time alloc] init];
    mTime8.time = @"8";
    mTime8.active = YES;
    
    Time *mTime9 = [[Time alloc] init];
    mTime9.time = @"9";
    mTime9.active = YES;
    
    Time *mTime10 = [[Time alloc] init];
    mTime10.time = @"10";
    mTime10.active = NO;
    
    Time *mTime11 = [[Time alloc] init];
    mTime11.time = @"11";
    mTime11.active = YES;
    
    [mondayTimes addObject:mTime8];
    [mondayTimes addObject:mTime9];
    [mondayTimes addObject:mTime10];
    [mondayTimes addObject:mTime11];
    
    Time *fTime8 = [[Time alloc] init];
    fTime8.time = @"8";
    fTime8.active = YES;
    
    Time *fTime9 = [[Time alloc] init];
    fTime9.time = @"9";
    fTime9.active = YES;
    
    Time *fTime10 = [[Time alloc] init];
    fTime10.time = @"10";
    fTime10.active = NO;
    
    Time *fTime11 = [[Time alloc] init];
    fTime11.time = @"11";
    fTime11.active = YES;
    
    [fridayTimes addObject:fTime8];
    [fridayTimes addObject:fTime9];
    [fridayTimes addObject:fTime10];
    [fridayTimes addObject:fTime11];
    
    Day *monday = [Day object];
    monday.times =  mondayTimes;

    Day *friday = [Day object];
    friday.times = fridayTimes;
    
    Schedule *schedule = [Schedule object];
    schedule.monday = monday;
    schedule.friday = friday;
    
    // ------- Saving schedule ------- //
    [schedule saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Schedule saved");
    }];
    // ------- Saving schedule ------- //
    
    Clinic *clinic  = [Clinic object];
    clinic.doctor = doctor;
    clinic.name = @"Hospital Angeles";
    clinic.street = @"Blvd. De la Luz";
    clinic.number = @"12";
    clinic.city = @"Mexico City";
    clinic.state = @"Mexico City";
    clinic.zipCode = @"22234";
    clinic.latitude = @"123123";
    clinic.longitude = @"231231";
    clinic.schedule = schedule;
    
    // ------- Saving clinic ------- //
    [clinic saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Clinic saved...");
    }];
    // ------- Saving clinic ------- //
    
//    User *user = [User object];
//    user.name = @"Monica";
//    user.lastName = @"Gutierrez";
//    user.secondLastName = @"Perez";
//    user.title = @"Sra.";
//    user.email = @"firstusr@gmail.com";
//    user.password = @"12345";
//    user.gender = @"F";
//    user.birthday = date;
//    user.phone = @"6767676767";
//    
//    // ------- Saving doctor ------- //
//    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        NSLog(@"User saved...");
//    }];
//    // ------- Saving doctor ------- //

}

@end
