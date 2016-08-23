//
//  ScanAnnotation.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 25/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "global.h"
#import "CoreDataEntities.h"

@interface ScanAnnotation : MKPointAnnotation

@property NSString *scanLocationID;
@property int32_t altitude;
@property int32_t radius;
@property MKCircle *circle;

- (instancetype)initWithScanLocation:(ScanLocations *)scanlocation;
- (instancetype)initWithLocation:(CLLocationCoordinate2D)location;
-(void)drawCircleWithRadius:(int)radius;

@end
