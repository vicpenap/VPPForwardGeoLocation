//
//  ForwardGeoLocExample.h
//  VPPForwardGeoLocation
//
//  Created by Víctor on 25/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "VPPMapHelper.h"


@interface ForwardGeoLocExample : UIViewController <UISearchBarDelegate> 


@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) VPPMapHelper *mapHelper;

@property (nonatomic, retain) IBOutlet UIButton *resignerButton;


@end
