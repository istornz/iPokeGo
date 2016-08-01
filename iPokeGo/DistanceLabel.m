//
//  DistanceLabel.m
//  iPokeGo
//
//  Created by Valeriy Pogoniev on 26/7/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "DistanceLabel.h"
#import "NSString+Formatting.h"
@import CoreLocation;

@implementation DistanceLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont boldSystemFontOfSize:10.0];
        self.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (void)setDistanceBetweenUser:(CLLocation *)user andLocation:(CLLocation *)location
{
    CLLocationDistance distance = [user distanceFromLocation:location];
    self.text = [NSString stringWithFormat:@"%.0fm", distance];
}

@end
