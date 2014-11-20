//
//  CustomAnnotation.m
//  FindDr
//
//  Created by GLBMXM0002 on 11/18/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

-(id) initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location subtitle:(NSString *) subtitle {

    self = [super init];

    if (self) {
        _title = newTitle;
        _coordinate = location;
        _subtitle = subtitle;
    }

    return self;

}

@end
