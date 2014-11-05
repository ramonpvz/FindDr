//
//  Schedule.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>
#import "Day.h"

@interface Schedule : PFObject <PFSubclassing>

@property Day *monday;
@property Day *tuesday;
@property Day *wednesday;
@property Day *thursday;
@property Day *friday;
@property Day *saturday;
@property Day *sunday;

@end
