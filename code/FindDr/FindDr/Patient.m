//
//  Patient.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/6/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Patient.h"
#import "Appointment.h"

@implementation Patient

@dynamic name;
@dynamic lastName;
@dynamic secondLastName;
@dynamic title;
@dynamic email;
@dynamic photo;
@dynamic gender;
@dynamic birthday;
@dynamic phone;
@dynamic user;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Patient";
}

- (void) getAppointments:(void (^)(NSArray *appointments))complete {
    PFQuery *appointmentsQuery = [Appointment query];
    [appointmentsQuery whereKey:@"patient" equalTo:self];
    [appointmentsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    } ];
}

+ (void) save: (Patient *) patient {
    if (patient.user != nil && patient.email != nil && [Patient validEmail:patient.email] ) {
        [patient saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Patient saved...");
        }];
    }
    else
    {
        NSLog(@"Patient is invalid.");
    }
}

+ (BOOL) validEmail : (NSString*) emailString {
    if ([emailString length] == 0) {
        return NO;
    }
    else
    {
        NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
        NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
        if (regExMatches == 0) {
            return NO;
        }
        else
        {
            return YES;
        }
    }
}

@end
