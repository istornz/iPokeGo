//
//  PokemonAnnotation.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 22/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokemonAnnotation.h"

@implementation PokemonAnnotation

-(PokemonAnnotation *)initWithJson:(NSDictionary *)data {
	CLLocationCoordinate2D pokemonLocation = CLLocationCoordinate2DMake([data[@"latitude"] floatValue], [data[@"longitude"] floatValue]);
	
	NSNumber *disappearTimestamp = [data valueForKey:@"disappear_time"];
	NSDate *disappearDate = [NSDate dateWithTimeIntervalSince1970:[disappearTimestamp longValue] / 1000];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"hh:mm:ss"];
	
	self.hidePokemon    = NO;
	self.spawnpointID   = [data objectForKey:@"spawnpoint_id"];
	self.encounterID	= [data objectForKey:@"encounter_id"];
	self.expirationDate = disappearDate;
	
	self.coordinate     = pokemonLocation;
	self.title          = [data objectForKey:@"name"];
	self.subtitle       = [NSString localizedStringWithFormat:NSLocalizedString(@"Disappears at", @"The hint in a annotation callout that indicates when a Pokémon disappears."), [dateFormatter stringFromDate:disappearDate]];
	self.pokemonID      = [[data objectForKey:@"pokemon_id"] intValue];
	
	return self;
}

@end
