//
//  Gym+CoreDataProperties.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "Gym+CoreDataProperties.h"

@implementation Gym (CoreDataProperties)

+ (NSFetchRequest<Gym *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Gym"];
}

@dynamic identifier;
@dynamic latitude;
@dynamic longitude;
@dynamic team;
@dynamic points;
@dynamic guardingPokemonIdentifier;

@end
