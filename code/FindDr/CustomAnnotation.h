//
//  CustomAnnotation.h
//  FindDr
//
//  Created by GLBMXM0002 on 11/18/14.
//  Copyright (c) 2014 FindDr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic) NSString *addressId;

-(id) initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location subtitle:(NSString *) subtitle;

@end