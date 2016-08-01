//
//  PokemonAnnotationView.h
//  iPokeGo
//
//  Created by Curtis herbert on 8/1/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

@import CoreLocation;
#import <MapKit/MapKit.h>
#import "PokemonAnnotation.h"
#import "TimeLabel.h"
#import "TimerLabel.h"
#import "DistanceLabel.h"

@interface PokemonAnnotationView : MKAnnotationView

@property (weak) TimeLabel* timeLabel;
@property (weak) TimerLabel* timerLabel;
@property (weak) DistanceLabel* distanceLabel;

- (instancetype)initWithAnnotation:(PokemonAnnotation *)annotation currentLocation:(CLLocation *)location reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setAnnotation:(id<MKAnnotation>)annotation withLocation:(CLLocation *)location;

@end
