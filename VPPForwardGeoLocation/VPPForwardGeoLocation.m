//
//  VPPForwardGeoLocation.m
//
//  Created by Víctor on 31/10/11.

// 	Copyright (c) 2012 Víctor Pena Placer (@vicpenap)
// 	http://www.victorpena.es/
// 	
// 	
// 	Permission is hereby granted, free of charge, to any person obtaining a copy 
// 	of this software and associated documentation files (the "Software"), to deal
// 	in the Software without restriction, including without limitation the rights 
// 	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// 	copies of the Software, and to permit persons to whom the Software is furnished
// 	to do so, subject to the following conditions:
// 	
// 	The above copyright notice and this permission notice shall be included in
// 	all copies or substantial portions of the Software.
// 	
// 	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// 	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// 	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// 	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// 	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
// 	IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


#import "VPPForwardGeoLocation.h"
#import "XMLReader.h"
#import "VPPForwardGeoLocationAnnotation.h"

#define kGMapsURL @"http://maps.googleapis.com/maps/geo?q=%@&output=xml"

@implementation VPPForwardGeoLocation

+ (NSArray *) parsePlacemarksArray:(NSArray *)placemarksArray {
    NSArray *locationComp;
    NSMutableArray *results = [NSMutableArray array];
    float latitude;
    float longitude;
    VPPForwardGeoLocationAnnotation *ann;
    NSDictionary *country;
    NSDictionary *locality;
    for (NSDictionary *placemark in placemarksArray) {
        ann = [[VPPForwardGeoLocationAnnotation alloc] init];
        
        country = [[placemark objectForKey:@"AddressDetails"] objectForKey:@"Country"];
        if ((locality = [country objectForKey:@"AdministrativeArea"])) {
            locality = [[locality objectForKey:@"SubAdministrativeArea"] objectForKey:@"Locality"];
        }
        else {
            locality = [[country objectForKey:@"SubAdministrativeArea"] objectForKey:@"Locality"];
        }
        
        
        NSString *address = [[[locality
                               objectForKey:@"Thoroughfare"]
                              objectForKey:@"ThoroughfareName"] 
                             objectForKey:@"text"];	
        if (address == nil) {
            address = [[placemark objectForKey:@"address"] objectForKey:@"text"];	
        }
        address = [address stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        ann.title = address;
        NSString *coordinatesString = [[[placemark objectForKey:@"Point"] objectForKey:@"coordinates"] objectForKey:@"text"];	
        coordinatesString = [coordinatesString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        locationComp = [coordinatesString componentsSeparatedByString:@","];
        longitude = [[locationComp objectAtIndex:0] floatValue];
        latitude = [[locationComp objectAtIndex:1] floatValue];		
        ann.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        [results addObject:ann];
        [ann release];
    }

    return results;
}

+ (void) locationsUsingForwardGeoLocation:(NSString*)addressString 
                                batchSize:(int)batchSize 
                               completion:(void (^) (NSArray *data))block {
    
    NSOperationQueue *q = [[NSOperationQueue alloc] init];
    [q addOperationWithBlock:^{
        NSError *error = nil;

        // builds url
        NSString *stringURL = [NSString stringWithFormat:kGMapsURL,[addressString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        // parses url
        NSString *parsed = [NSString stringWithContentsOfURL:[NSURL URLWithString:stringURL]
                                                    encoding:NSUTF8StringEncoding error:&error];
    
        if (parsed == nil || error != nil) {
            // something went wrong
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                block(nil);
            }];
            return;
        }
        
        NSDictionary *dictionaryParsed = [XMLReader dictionaryForXMLString:parsed error:&error];
        if (error != nil) {
            // something went wrong
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                block(nil);
            }];
            return;
        }
        
        // get xml placemarks objects. They hold all interesting info
        NSArray *placemarks = [[[dictionaryParsed objectForKey:@"kml"] objectForKey:@"Response"] objectForKey:@"Placemark"];	
        
        if (placemarks == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                block(nil);
            }];
            return;
        }
        
        // if there's only one placemark, let's put it into a new array
        if (![placemarks isKindOfClass:[NSArray class]]) {
            placemarks = [NSArray arrayWithObject:placemarks];
        }
        
        else if ([placemarks count] > batchSize) {
            placemarks = [placemarks subarrayWithRange:NSMakeRange(0, batchSize)];
        }
        
        NSArray *results = [VPPForwardGeoLocation parsePlacemarksArray:placemarks];
                
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(results);
        }];
    }];
    [q release];
}
@end
