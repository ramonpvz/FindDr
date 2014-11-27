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
@dynamic reviews;
@dynamic average;

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

+ (void) rate: (NSInteger*) value
{
    
}

- (void) getRankingByDoc: (Doctor *) doctor result: (void (^) (Ranking* ranking)) complete
{
    PFQuery *rankingQuery = [Ranking query];
    [rankingQuery whereKey:@"doctor" equalTo:doctor];
    [rankingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        double dividend, rawAverage;
        NSArray *sortedResult = [objects sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSNumber *first = [(Ranking* )a ranking];
            NSNumber *second = [(Ranking*)b ranking];
            return [first compare:second];
        }];
        for (int i = 0; i < 5; i++) {
            NSString *predStr = [NSString stringWithFormat:@"SELF.ranking == %i",i+1];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predStr];
            NSArray *filteredRanking = [sortedResult filteredArrayUsingPredicate:predicate];
            if (filteredRanking.count > 0) {
                dividend += filteredRanking.count * (i+1);
            }
        }
        rawAverage = dividend / objects.count;
        double rounded = round(rawAverage * 100.0)/100;
        NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
        [fmt setMaximumFractionDigits:1];
        NSString *ranking = [fmt stringFromNumber:[NSNumber numberWithDouble:rounded]];
        self.reviews = [NSNumber numberWithInt:(int)objects.count];
        self.average = @([ranking doubleValue]);
        complete(self);
    }];
}

+ (void) countReviews: (Doctor *) doctor pat: (Patient *) patient result: (void (^) (NSNumber* reviews)) complete {
    PFQuery *reviewsQuery = [Ranking query];
    [reviewsQuery whereKey:@"doctor" equalTo:doctor];
    [reviewsQuery whereKey:@"patient" equalTo:patient];
    [reviewsQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        complete([NSNumber numberWithInt:number]);
    }];
}

@end