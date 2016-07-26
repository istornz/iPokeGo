//
//  DistanceLabel.m
//  iPokeGo
//
//  Created by Valeriy Pogoniev on 26/7/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "DistanceLabel.h"

@implementation DistanceLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont systemFontOfSize:13.0];
        self.textAlignment = NSTextAlignmentRight;
        self.layer.shadowColor = [UIColor whiteColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    }
    return self;
}

- (void)setDistance:(double)distance {
    self.text = [NSString stringWithFormat:@"%.0fm", distance];
}

@end
