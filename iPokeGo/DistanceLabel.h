//
//  DistanceLabel.h
//  iPokeGo
//
//  Created by Valeriy Pogoniev on 26/7/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;

@interface DistanceLabel : UILabel

- (void)setDistanceBetweenUser:(CLLocation *)user andLocation:(CLLocation *)location;

@end
