//
//  GymAnnotation.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 22/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface GymAnnotation : MKPointAnnotation

@property int gymsID;
@property int guardPokemonID;
@property int gym_points;

@end
