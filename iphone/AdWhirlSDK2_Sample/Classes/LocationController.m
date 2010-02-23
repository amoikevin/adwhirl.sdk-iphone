//
//  LocationController.m
//  AdWhirlSDK2_Sample
//
//  Created by Nigel Choi on 2/8/10.
//  Copyright 2010 Admob. Inc.. All rights reserved.
//

#import "LocationController.h"
#import "AdWhirlLog.h"

@implementation LocationController

- (id)init {
  if (self = [super initWithNibName:@"LocationController" bundle:nil]) {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
  }
  return self;
}

- (UILabel *)locLabel {
  return (UILabel *)[self.view viewWithTag:103];
}

- (void)dealloc {
  locationManager.delegate = nil;
  [locationManager release], locationManager = nil;
  [super dealloc];
}


#pragma mark AdWhirlDelegate methods

- (CLLocation *)locationInfo {
  CLLocation *loc = [locationManager location];
  AWLogDebug(@"AdWhirl asking for location: %@", loc);
  return loc;
}


#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  [locationManager stopUpdatingLocation];
  self.locLabel.text = [NSString stringWithFormat:@"Error getting location: %@",
                        [error localizedDescription]];
  AWLogError(@"Failed getting location: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  self.locLabel.text = [NSString stringWithFormat:@"%lf %lf",
                        newLocation.coordinate.longitude,
                        newLocation.coordinate.latitude];
}

@end
