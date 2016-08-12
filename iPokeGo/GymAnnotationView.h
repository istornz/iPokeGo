//
//  GymAnnotationView.h
//  iPokeGo
//
//  Created by Curtis herbert on 8/1/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "GymAnnotation.h"
#import "global.h"
#import "TagLabel.h"

@interface GymAnnotationView : MKAnnotationView

- (instancetype)initWithAnnotation:(GymAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end
