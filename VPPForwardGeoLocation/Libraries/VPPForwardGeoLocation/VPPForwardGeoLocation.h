//
//  VPPForwardGeoLocation.h
//
//  Created by Víctor on 31/10/11.
//  Copyright 2011 Víctor Pena Placer. All rights reserved.
//

#import <Foundation/Foundation.h>

/** VPPForwardGeoLocation is a block-based library that can get locations
from a given search string, something like iOS Maps application. 

Locations will be instances of VPPForwardGeoLocationAnnotation class. */
@interface VPPForwardGeoLocation : NSObject

/** Performs a background request and calls block in the main thread 
passing the locations found as parameter.

@param addressString The string to search.
@param batchSize Max amount of locations to return.
@param block The block to be called when the search is finished. `data` 
will hold the locations found as an array of VPPForwardGeoLocationAnnotation
instances. It will be `nil` if an error occurs or no location is found. */
+ (void) locationsUsingForwardGeoLocation:(NSString*)addressString 
                                batchSize:(int)batchSize 
                               completion:(void (^) (NSArray *data))block;

@end
