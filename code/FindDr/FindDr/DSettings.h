//
//  DSettings.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/11/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DSettings : NSObject

- (instancetype) init;

-(NSURL *) documentsDirectory;

-(void) add: (NSDictionary *) item;

-(void) remove: (NSString *) key;

- (NSArray *) getPList;

- (void) createDefaultSettings;

@end
