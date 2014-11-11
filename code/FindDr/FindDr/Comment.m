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

+ (void) load
{
    [self registerSubclass];
}

+ (NSString *) parseClassName {
    return @"Comment";
}

@end
