//
//  Comment.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/5/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "Comment.h"

@implementation Comment

@dynamic description;
@dynamic patient;
@dynamic doctor;

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Comment";
}

+ (void) getCommentsByPatient:(Patient *)patient doc:(void (^)(NSArray *comments))complete {
    PFQuery *commentQuery = [Comment query];
    [commentQuery whereKey:@"patient" equalTo:patient];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];
}

+ (void) getCommentsByDoctor:(Doctor *)doctor doc:(void (^)(NSArray *comments))complete {
    PFQuery *commentQuery = [Comment query];
    [commentQuery whereKey:@"doctor" equalTo:doctor];
    [commentQuery includeKey:@"patient"];
    [commentQuery orderByDescending:@"createdAt"];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];
}

+ (void) addCommentToDoctor:(NSString *)description doctor:(Doctor *)doctor patient:(Patient *)patient {
    Comment *comment = [Comment object];
    comment.description = description;
    comment.doctor = doctor;
    comment.patient = patient;
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Comment added");
        }
        else
        {
            NSLog(@"Error: %@",error);
        }
    }];
}

@end
