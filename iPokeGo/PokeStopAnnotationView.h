//
//  PokeStopAnnotationView.h
//  iPokeGo
//
//  Created by Curtis herbert on 8/1/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "PokestopAnnotation.h"

@interface PokeStopAnnotationView : MKAnnotationView

- (instancetype)initWithAnnotation:(PokestopAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end
