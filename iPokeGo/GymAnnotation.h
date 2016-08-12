//
//  GymAnnotation.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 22/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "CoreDataEntities.h"

@interface GymAnnotation : MKPointAnnotation

@property NSString *gymID;
@property int teamID;
@property int guardPokemonID;
@property int gymPoints;
@property int gymLvl;

- (instancetype)initWithGym:(Gym *)gym;

@end
