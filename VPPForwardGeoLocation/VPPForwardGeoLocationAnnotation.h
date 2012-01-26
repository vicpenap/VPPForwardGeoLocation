//
//  VPPForwardGeoLocationAnnotation.h
//
//  Created by Víctor on 31/10/11.
//  Copyright 2011 Víctor Pena Placer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

/** This class holds the location title and coordinate. It implements
MKAnnotation protocol, so it can be directly added to a MKMapView.
*/
@interface VPPForwardGeoLocationAnnotation : NSObject <MKAnnotation>

/** Annotation's title */
@property (nonatomic, copy) NSString *title;
/** Annotation's coordinate */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
