//
//  PokemonNotifier.h
//  iPokeGo
//
//  Created by Curtis herbert on 7/30/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapViewController.h"

@interface PokemonNotifier : NSObject

@property (weak) MapViewController *mapViewController;

- (void)notificationTapped:withNotification;
@end
