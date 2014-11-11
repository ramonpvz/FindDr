//
//  DSettings.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/11/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "DSettings.h"

@interface DSettings ()

@property NSMutableArray *drSettings;

@end

@implementation DSettings

- (instancetype) init {
    self = [super init];
    [self load];
    return self;
}

-(NSURL *) documentsDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager]; //Returns a "Singletone"
    NSArray *files = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]; //As for a URL using Domain Mask
    return files.firstObject; //Asking for all the local directories (Universal Resource Locator)
}

- (void) createDefaultSettings {
    [self add:@{@"language":@"english"}];
    [self add:@{@"notifications":@"yes"}];
    [self add:@{@"radio":@"19.4286567,-99.1614878"}];
    [self add:@{@"about":@"FindDr V1.0"}];
    [self add:@{@"feedback":@"feedback@finddr.com"}];
    [self add:@{@"share":@""}];
    [self add:@{@"appstore":@""}];
}

-(void) load {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSURL *pList = [[self documentsDirectory] URLByAppendingPathComponent:@"drsettings.pList"];
    self.drSettings = [NSMutableArray arrayWithContentsOfURL:pList];
    NSLog(@"date: %@", [userDefaults objectForKey:@"LastSaved"]);
}

-(void) add: (NSDictionary *) item {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSURL *pList = [[self documentsDirectory] URLByAppendingPathComponent:@"drsettings.pList"];
    [self.drSettings addObject:item];
    [self.drSettings writeToURL:pList atomically:YES];
    [userDefaults setObject:[NSDate date] forKey:@"LastSaved"];
    [userDefaults synchronize];
}

-(void) remove: (NSString *) key {
    for (int i = 0; i < self.drSettings.count; i++) {
        NSDictionary *dict = [self.drSettings objectAtIndex:i];
        if ([dict objectForKey:key] != nil) {
            [self.drSettings removeObjectAtIndex:i];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSURL *pList = [[self documentsDirectory] URLByAppendingPathComponent:@"drsettings.pList"];
            [self.drSettings writeToURL:pList atomically:YES];
            [userDefaults setObject:[NSDate date] forKey:@"LastSaved"];
            [userDefaults synchronize];
        }
    }
}

- (NSArray *) getPList {
    return [NSArray arrayWithArray:self.drSettings];
}

@end
