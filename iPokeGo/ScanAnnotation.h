//
//  ScanAnnotation.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 25/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CoreDataEntities.h"

@interface ScanAnnotation : MKPointAnnotation

@property NSString *scanLocationID;
@property int32_t altitude;
@property double latitude;
@property double longitude;
@property int32_t radius;

- (instancetype)initWithScanLocation:(ScanLocations *)scanlocation;

@end
