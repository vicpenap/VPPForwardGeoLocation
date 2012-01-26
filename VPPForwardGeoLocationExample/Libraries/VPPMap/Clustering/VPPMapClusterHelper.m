//
//  VPPMapClusterHelper.m
//  VPPLibraries
//
//  Created by Víctor on 09/12/11.
//  Copyright (c) 2011 Víctor Pena Placer. All rights reserved.
//

#import "VPPMapClusterHelper.h"
#import "VPPMapCluster.h"
#import "VPPMapCustomAnnotation.h"


/* Based on DBSCAN algorithm */

@implementation VPPMapClusterHelper
@synthesize mapView;

- (VPPMapClusterHelper *) initWithMapView:(MKMapView*)mmapView {
    if (self = [super init]) {
        self.mapView = mmapView;
    }
    
    return self;
}

- (void) dealloc {
    self.mapView = nil;
    [super dealloc];
}

- (float) approxDistanceCoord1:(CLLocationCoordinate2D)coord1 coord2:(CLLocationCoordinate2D)coord2 {
    //now properly convert this mapPoint to CGPoint 
    CGPoint pt1;
    CGFloat zoomFactor =  self.mapView.visibleMapRect.size.width / self.mapView.bounds.size.width;
    MKMapPoint mapPoint1 = MKMapPointForCoordinate(coord1);  
    pt1.x = mapPoint1.x/zoomFactor;
    pt1.y = mapPoint1.y/zoomFactor;
    
    CGPoint pt2;
    MKMapPoint mapPoint2 = MKMapPointForCoordinate(coord2);  
    pt2.x = mapPoint2.x/zoomFactor;
    pt2.y = mapPoint2.y/zoomFactor;
    
    
    int dx = (int)pt1.x - (int)pt2.x;
    int dy = (int)pt1.y - (int)pt2.y;
    dx = abs(dx);
    dy = abs(dy);
    if ( dx < dy ) {
        return dx + dy - (dx >> 1);
    } else {
        return dx + dy - (dy >> 1);
    }
}

- (BOOL) shouldAvoidClustersAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return YES;
    }
    
    if ([annotation conformsToProtocol:@protocol(VPPMapCustomAnnotation)]) {
        if ([annotation respondsToSelector:@selector(avoidsClusters)]) {
            if ([(id<VPPMapCustomAnnotation>)annotation avoidsClusters]) {
                return YES;
            }
        }
    }    
    
    return NO;
}


- (NSArray*) findNeighboursForAnnotation:(id<MKAnnotation>)ann inNeighbourdhood:(NSArray*)neighbourhood withDistance:(float)distance
{
    
    NSMutableArray *result = [NSMutableArray array];
    for (id<MKAnnotation> k in neighbourhood)
    {
        if (k == ann) {
            continue;
        }
        
        if ([self shouldAvoidClustersAnnotation:k]) {
            continue;
        }
        
        if ([self approxDistanceCoord1:ann.coordinate coord2:k.coordinate] < distance)
        {
            [result addObject:k];            
        }
    }
    
    if ([result count] == 0) {
        return nil;
    }
    return result;
}


- (void) clustersForAnnotations:(NSArray*)annotations distance:(float)distance completion:(void (^)(NSArray *data))block {
    NSOperationQueue *q = [[NSOperationQueue alloc] init];
    [q addOperationWithBlock:^{
        NSMutableArray *processed = [NSMutableArray array];
        NSMutableArray *restOfAnnotations = [NSMutableArray arrayWithArray:annotations];
        NSMutableArray *finalAnns = [NSMutableArray array];
        
        
        for (id<MKAnnotation> ann in annotations) {
            if ([processed containsObject:ann]) {
                continue;
            }
            [processed addObject:ann];
            
            if ([self shouldAvoidClustersAnnotation:ann]) {
                [finalAnns addObject:ann];
                continue;                
            }
            
            NSArray *neighbours = [self findNeighboursForAnnotation:ann inNeighbourdhood:restOfAnnotations withDistance:distance];
            
            if (!neighbours) {
                [finalAnns addObject:ann];
            }
            
            else {
                [processed addObjectsFromArray:neighbours];
                
                VPPMapCluster *cluster = [[VPPMapCluster alloc] init];
                [cluster.annotations addObjectsFromArray:neighbours];
                [cluster.annotations addObject:ann];
                [finalAnns addObject:cluster];
                [cluster release];
            }
            
            [restOfAnnotations removeObjectsInArray:processed];
        }
        
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            block(finalAnns);
        }];
    }];
    [q release];
}


@end
