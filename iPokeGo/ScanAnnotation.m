//
//  ScanAnnotation.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 25/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "ScanAnnotation.h"

@implementation ScanAnnotation

- (instancetype)initWithLocation:(CLLocationCoordinate2D)location
{
    if(self = [super init])
    {
        self.radius         = DEFAULT_RADIUS;
        self.title          = NSLocalizedString(@"Scan location", @"The title of an annotation on the map to scan the location.");
        self.coordinate     = location;
        self.circle         = [MKCircle circleWithCenterCoordinate:self.coordinate radius:self.radius];
    }
    
    return self;
}

- (instancetype)initWithScanLocation:(ScanLocations *)scanlocation
{
    if (self = [super init]) {
        self.scanLocationID = scanlocation.identifier;
        self.altitude       = scanlocation.altitude;
        self.coordinate     = scanlocation.location;
        self.radius         = scanlocation.radius;
        self.title          = NSLocalizedString(@"Scan location", @"The title of an annotation on the map to scan the location.");
        self.circle         = [MKCircle circleWithCenterCoordinate:scanlocation.location radius:scanlocation.radius];
    }
    return self;
}

@end
