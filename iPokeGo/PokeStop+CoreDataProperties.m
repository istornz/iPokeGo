//
//  PokeStop+CoreDataProperties.m
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokeStop+CoreDataProperties.h"

@implementation PokeStop (CoreDataProperties)

+ (NSFetchRequest<PokeStop *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"PokeStop"];
}

@dynamic identifier;
@dynamic latitude;
@dynamic longitude;
@dynamic lureExpiration;

@end
