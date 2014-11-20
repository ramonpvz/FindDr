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
    //to do...
}

+ (void) getCommentsByDoctor:(Doctor *)doctor doc:(void (^)(NSArray *comments))complete {
    //to do...
}

+ (void) addCommentToDoctor: (NSString *) doctor : (Doctor *) doc {
    //to do...
}

@end
