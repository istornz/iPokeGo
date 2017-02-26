//
//  PokemonAnnotationLabel.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 01/12/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokemonAnnotationLabel.h"

@implementation PokemonAnnotationLabel

- (instancetype)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

-(void)setup {
    
    self.textColor                  = [UIColor whiteColor];
    self.textAlignment              = NSTextAlignmentCenter;
    self.layer.cornerRadius         = 8.0f;
    self.font                       = [UIFont fontWithName:@"HelveticaNeue" size:10.0f];
    self.backgroundColor            = [UIColor clearColor];
    self.layer.backgroundColor      = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.0].CGColor;
    self.layer.masksToBounds        = NO;
    self.layer.shouldRasterize      = YES;
    self.layer.rasterizationScale   = [UIScreen mainScreen].scale;
}

-(void)setLabelText:(NSString *)text
{
    self.text = text;
    [self sizeToFit];
    
    self.font = [UIFont fontWithName:@"HelveticaNeue" size:10.0f];
    
    CGRect frameLbl = self.frame;
    frameLbl.size.height += 10;
    frameLbl.size.width += 10;
    self.frame = frameLbl;
}

@end
