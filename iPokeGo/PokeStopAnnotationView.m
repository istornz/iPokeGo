//
//  PokeStopAnnotationView.m
//  iPokeGo
//
//  Created by Curtis herbert on 8/1/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokeStopAnnotationView.h"
#import "global.h"

@implementation PokeStopAnnotationView

- (instancetype)initWithAnnotation:(PokestopAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.canShowCallout = YES;
        if(annotation.hasLure) {
            self.image = [UIImage imageNamed:@"PokestopLured"];
            UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            NSMutableArray *images = [[NSMutableArray alloc] init];
            for (int i = 0; i < 24; i++) {
                [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"PokestopLuredAnimation-%@", @(i)]]];
            }
            animatedImageView.animationImages = images;
            animatedImageView.animationDuration = 1.0f;
            [animatedImageView startAnimating];
            [self addSubview: animatedImageView];
            
        } else {
            self.image = [UIImage imageNamed:@"PokestopUnlured"];
        }
        [self updateForAnnotation:annotation];
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    super.annotation = annotation;
    [self updateForAnnotation:annotation];
}

- (void)updateForAnnotation:(PokestopAnnotation *)annotation
{
    if (annotation.luredPokemonID && annotation.luredPokemonID != 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Pokemon_%@", @(annotation.luredPokemonID)]]];
        imageView.frame = CGRectMake(0, 0, 45, 45);
        self.leftCalloutAccessoryView = imageView;
        
    } else {
        self.leftCalloutAccessoryView = nil;
    }

}

@end
