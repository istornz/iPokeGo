//
//  DistanceLabel.m
//  iPokeGo
//
//  Created by Valeriy Pogoniev on 26/7/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "DistanceLabel.h"
#import "NSString+Formatting.h"

@implementation DistanceLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont boldSystemFontOfSize:13.0];
        self.textAlignment = NSTextAlignmentRight;
    }
    return self;
}

- (void)setDistance:(double)distance {
    self.attributedText = [NSString stringWithFormat:@"%.0fm", distance].outlinedAttributedString;
}

@end
