//
//  Search.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/14/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Parse/Parse.h>

@interface Search : NSObject

- (void) search: (NSString *)searchString results: (void(^)(NSArray *results))complete;

@end
