//
//  ForwardGeoLocExample.m
//  VPPForwardGeoLocation
//
//  Created by Víctor on 25/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ForwardGeoLocExample.h"
#import "VPPForwardGeoLocation.h"

@implementation ForwardGeoLocExample
@synthesize mapView, searchBar, resignerButton, mapHelper;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mapHelper = [VPPMapHelper VPPMapHelperForMapView:self.mapView pinAnnotationColor:MKPinAnnotationColorRed centersOnUserLocation:NO showsDisclosureButton:NO delegate:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.mapHelper = nil;
    self.mapView = nil;
    self.searchBar = nil;
    self.resignerButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction) resignResponders {
    [self.searchBar resignFirstResponder];
    self.resignerButton.hidden = YES;
}

- (void) search {
    [VPPForwardGeoLocation locationsUsingForwardGeoLocation:self.searchBar.text batchSize:10 completion:^(NSArray *data) {
        [self.mapHelper setMapAnnotations:data];
    }];
}

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.resignerButton.hidden = NO;
    
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self search];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self resignResponders];
}
@end
