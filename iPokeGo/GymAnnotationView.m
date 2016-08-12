//
//  GymAnnotationView.m
//  iPokeGo
//
//  Created by Curtis herbert on 8/1/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "GymAnnotationView.h"
#import "global.h"

@implementation GymAnnotationView

- (instancetype)initWithAnnotation:(GymAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.canShowCallout = YES;
        
        TagLabel *tagLabelView = [[TagLabel alloc] init];
        [tagLabelView setLabelText:[NSString stringWithFormat:@"LVL %d", annotation.gymLvl]];
        
        UIColor *bgColorTag;
        switch (annotation.teamID) {
            case TEAM_BLUE:
                self.image  = [UIImage imageNamed:@"GymMystic"];
                bgColorTag  = TEAM_COLOR_BLUE;
                break;
            case TEAM_RED:
                self.image  = [UIImage imageNamed:@"GymValor"];
                bgColorTag  = TEAM_COLOR_RED;
                break;
            case TEAM_YELLOW:
                self.image  = [UIImage imageNamed:@"GymInstinct"];
                bgColorTag  = TEAM_COLOR_YELLOW;
                break;
            default:
                self.image  = [UIImage imageNamed:@"GymUnowned"];
                bgColorTag  = TEAM_COLOR_GRAY;
                break;
        }
        
        [tagLabelView setBackgroundColor:bgColorTag];
        
        self.rightCalloutAccessoryView = tagLabelView;
        
        [self updateForAnnotation:annotation];
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation
{
    super.annotation = annotation;
    
    [self updateForAnnotation:annotation];
}

- (void)updateForAnnotation:(GymAnnotation *)annotation
{
    GymAnnotation *gym = self.annotation;
    if (gym.guardPokemonID && gym.guardPokemonID != 0) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Pokemon_%@", @(gym.guardPokemonID)]]];
        imageView.frame = CGRectMake(0, 0, 45, 45);
        self.leftCalloutAccessoryView = imageView;
        
    } else {
        self.leftCalloutAccessoryView = nil;
    }
}

@end
