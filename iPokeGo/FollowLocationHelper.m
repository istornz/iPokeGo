//
//  FollowLocationHelper.m
//  iPokeGo
//
//  Created by David on 12/8/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "FollowLocationHelper.h"


@interface FollowLocationHelper()

@property CLLocation *lastLocation;

@end

@implementation FollowLocationHelper

// Update the map if more than N meters away from the center.
// (AND'd with UPDATE_MAP_MIN_TIME_MINUTES)
static float const UPDATE_MAP_MIN_DISTANCE_METERS = 500.0;

// Update the map if it hasn't been updated in n seconds.
// (AND'd with UPDATE_MAP_MIN_DISTANCE_METERS)
static NSTimeInterval const UPDATE_MAP_MIN_TIME_SEC = 120.0;

- (void)updateLocation:(CLLocation *)location
{
    self.lastLocation = location;
}

- (BOOL)mustUpdateLocation:(CLLocation *)location
{
    NSLog(@"Seconds --------> %f",[[NSDate date] timeIntervalSinceDate: self.lastLocation.timestamp]);
    NSLog(@"Distance -------> %f",[location distanceFromLocation:self.lastLocation]);
    return self.lastLocation == nil ||
        ([self.lastLocation.timestamp timeIntervalSinceNow] < -UPDATE_MAP_MIN_TIME_SEC
    && [location distanceFromLocation:self.lastLocation] > UPDATE_MAP_MIN_DISTANCE_METERS);
}

@end