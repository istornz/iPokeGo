//
//  PokemonAnnotationView.m
//  iPokeGo
//
//  Created by Curtis herbert on 8/1/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "PokemonAnnotationView.h"
#import "global.h"

@interface PokemonAnnotationView()

@property CLLocation *location;

@end

@implementation PokemonAnnotationView

- (instancetype)initWithAnnotation:(PokemonAnnotation *)annotation currentLocation:(CLLocation *)location reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *btnImage   = [UIImage imageNamed:@"drive"];
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setImage:btnImage forState:UIControlStateNormal];
        
        self.canShowCallout = YES;
        self.rightCalloutAccessoryView = button;
        self.image = [UIImage imageNamed:[NSString stringWithFormat:@"Pokemon_%@", @(annotation.pokemonID)]];
        self.frame = CGRectMake(0, 0, 45, 45);
        self.location = location;
        
        UIColor *bgColor = COLOR_COMMON;
        if([annotation.rarity isEqualToString:@"Uncommon"])
            bgColor = COLOR_UNCOMMON;
        else if([annotation.rarity isEqualToString:@"Rare"])
            bgColor = COLOR_RARE;
        else if([annotation.rarity isEqualToString:@"Very Rare"])
            bgColor = COLOR_VERYRARE;
        else if([annotation.rarity isEqualToString:@"Ultra Rare"])
            bgColor = COLOR_ULTRARARE;

        if([annotation.rarity length] > 0)
        {
            TagLabel *tagLabelView = [[TagLabel alloc] init];
            [tagLabelView setLabelText:annotation.rarity.uppercaseString];
            [tagLabelView setBackgroundColor:bgColor];
            self.leftCalloutAccessoryView = tagLabelView;
        }
        
        [self updateForAnnotation:annotation withLocation:location];
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation withLocation:(CLLocation *)location
{
    self.location = location;
    super.annotation = annotation;
    
    [self updateForAnnotation:annotation withLocation:location];
}

- (void)updateForAnnotation:(PokemonAnnotation *)annotation withLocation:(CLLocation *)location
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"display_time"] && ![defaults boolForKey:@"display_timer"]) {
        if (!self.timeLabel) {
            TimeLabel *timeLabelView = [self timeLabelForAnnotation:annotation withContainerFrame:self.frame];
            [self addSubview:timeLabelView];
            self.timeLabel = timeLabelView;
        } else {
            [self.timeLabel setDate:annotation.expirationDate];
        }
    } else {
        [self.timeLabel removeFromSuperview];
    }
    
    if ([defaults boolForKey:@"display_timer"]) {
        if (!self.timerLabel) {
            TimerLabel *timerLabelView = [self timerLabelForAnnotation:annotation withContainerFrame:self.frame];
            [self addSubview:timerLabelView];
            self.timerLabel = timerLabelView;
        } else {
            [self.timerLabel setDate:annotation.expirationDate];
        }
    } else {
        [self.timerLabel removeFromSuperview];
    }
    
    if ([defaults boolForKey:@"display_distance"]) {
        if (!self.distanceLabel) {
            DistanceLabel *distaneView = [self distanceLabelForAnnotation:annotation withContainerFrame:self.frame andCurrentLocation:location];
            [self addSubview:distaneView];
            self.distanceLabel = distaneView;
        } else {
            CLLocation *pokemonLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
            [self.distanceLabel setDistanceBetweenUser:location andLocation:pokemonLocation];
        }
    } else {
        [self.distanceLabel removeFromSuperview];
    }
}

- (TimeLabel*)timeLabelForAnnotation:(PokemonAnnotation*)annotation withContainerFrame:(CGRect)frame {
    TimeLabel *timeLabel = [[TimeLabel alloc] initWithFrame:CGRectMake(13, -1, 40, 10)];
    [timeLabel setDate:annotation.expirationDate];
    return timeLabel;
}

- (TimerLabel*)timerLabelForAnnotation:(PokemonAnnotation*)annotation withContainerFrame:(CGRect)frame {
    TimerLabel *timerLabel = [[TimerLabel alloc] initWithFrame:CGRectMake(13, -1, 40, 10)];
    [timerLabel setDate:annotation.expirationDate];
    return timerLabel;
}

- (DistanceLabel*)distanceLabelForAnnotation:(PokemonAnnotation*)annotation withContainerFrame:(CGRect)frame andCurrentLocation:(CLLocation *)location {
    CLLocation *pokemonLocation = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    DistanceLabel *distanceLabel = [[DistanceLabel alloc] initWithFrame:CGRectMake(-7, 45, 50, 10)];
    [distanceLabel setDistanceBetweenUser:location andLocation:pokemonLocation];
    return distanceLabel;
}

@end
