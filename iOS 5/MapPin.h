//
//  MapPin.h
//  MapDemo
//
//  Created by Mason Silber on 2/28/13.
//  Copyright (c) 2013 Mason Silber. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapPin : NSObject<MKAnnotation>

@property (nonatomic, strong) NSString *title, *subtitle;
@property CLLocationCoordinate2D coordinate;

@end
