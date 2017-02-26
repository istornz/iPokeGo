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
        
        [self loadLocalization];
        [self loadTheme];
        
        UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *btnImage   = [UIImage imageNamed:@"drive"];
        button.frame = CGRectMake(0, 0, 30, 30);
        [button setImage:btnImage forState:UIControlStateNormal];
        
        self.canShowCallout = YES;
        self.rightCalloutAccessoryView = button;
        
        if(self.pathTheme.length > 0) {
            self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/images/%@.png", self.pathTheme,@(annotation.pokemonID)]];
        } else {
            PokemonAnnotationLabel *labelPokemonName = [[PokemonAnnotationLabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
            [labelPokemonName setText:[NSString stringWithFormat:@"%@", [self.localization objectForKey:[NSString stringWithFormat:@"%d", annotation.pokemonID]]]];
            [self addSubview:labelPokemonName];
        }
        
        self.frame = CGRectMake(0, 0, 45, 45);
        self.location = location;
        
        if([annotation.rarity length] > 0 || annotation.iv > 0)
        {
            UIColor *bgColor;
            TagLabel *tagLabelView = [[TagLabel alloc] init];
            if(annotation.iv > 0) {
                //Display IV instead of rarity
                
                if((annotation.iv <= 20.0)) {
                    bgColor = COLOR_COMMON;
                } else if((annotation.iv > 20.0) && (annotation.iv <= 40.0)) {
                    bgColor = COLOR_UNCOMMON;
                } else if((annotation.iv > 40.0) && (annotation.iv <= 70.0)) {
                    bgColor = COLOR_RARE;
                } else if((annotation.iv > 70.0) && (annotation.iv <= 90)) {
                    bgColor = COLOR_VERYRARE;
                } else if((annotation.iv > 90) && (annotation.iv <= 100)) {
                    bgColor = COLOR_ULTRARARE;
                    // Wow pokemon is very strong !
                    // Let's user know it :)
                    [self addHoveredImage:[UIImage imageNamed:@"hot_pokemon"]];
                }
                
                [tagLabelView setLabelText:[NSString stringWithFormat:@"IV: %.f%%", annotation.iv]];
                [tagLabelView setBackgroundColor:bgColor];
                self.leftCalloutAccessoryView = tagLabelView;
                
            } else {
                if([annotation.rarity length] > 0)
                {
                    if([annotation.rarity isEqualToString:@"Uncommon"])
                        bgColor = COLOR_UNCOMMON;
                    else if([annotation.rarity isEqualToString:@"Rare"])
                        bgColor = COLOR_RARE;
                    else if([annotation.rarity isEqualToString:@"Very Rare"])
                        bgColor = COLOR_VERYRARE;
                    else if([annotation.rarity isEqualToString:@"Ultra Rare"])
                        bgColor = COLOR_ULTRARARE;
                    else
                        bgColor = COLOR_COMMON;
                    
                    [tagLabelView setLabelText:NSLocalizedString(annotation.rarity.uppercaseString, @"Pokemon rarity annotation label")];
                    [tagLabelView setBackgroundColor:bgColor];
                    self.leftCalloutAccessoryView = tagLabelView;
                }
            }
        }
        
        [self updateForAnnotation:annotation withLocation:location];
    }
    return self;
}

-(void)loadLocalization {
    NSError *error;
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"pokemon" withExtension:@"json"];
    
    self.localization = [[NSDictionary alloc] init];
    
    NSString *stringPath = [filePath absoluteString];
    NSData *localizationData = [NSData dataWithContentsOfURL:[NSURL URLWithString:stringPath]];
    
    self.localization = [NSJSONSerialization JSONObjectWithData:localizationData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
}


-(void)loadTheme {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *themeInstalled = [defaults objectForKey:@"themeInstalled"];
    
    if([themeInstalled count] > 0) {
        
        if([themeInstalled[@"dir"] length] == 0) {
            self.pathTheme = @"";
        } else {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            self.pathTheme = [NSString stringWithFormat:@"%@/%@", documentsDirectory, themeInstalled[@"dir"]];
        }
    }
}

-(void)addHoveredImage:(UIImage *)image
{
    CGSize size = CGSizeMake(45, 45);
    
    // Add option for retina screen
    UIGraphicsBeginImageContextWithOptions(size, false, [[UIScreen mainScreen] scale]);
    
    [self.image drawInRect:CGRectMake(0,0,size.width, size.height)];
    [image drawInRect:CGRectMake(0,0, 15, 15)];
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //set finalImage to IBOulet UIImageView
    self.image = finalImage;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation withLocation:(CLLocation *)location
{
    self.location = location;
    super.annotation = annotation;
    
    [self updateForAnnotation:annotation withLocation:location];
}

- (void)updateForAnnotation:(PokemonAnnotation *)annotation withLocation:(CLLocation *)location
{
    if(annotation.iv > 0)
    {
        TagLabel *tagLabelView = [[TagLabel alloc] init];
        UIColor *bgColor;
        //Display IV instead of rarity
        
        if((annotation.iv <= 20.0)) {
            bgColor = COLOR_COMMON;
        } else if((annotation.iv > 20.0) && (annotation.iv <= 40.0)) {
            bgColor = COLOR_UNCOMMON;
        } else if((annotation.iv > 40.0) && (annotation.iv <= 70.0)) {
            bgColor = COLOR_RARE;
        } else if((annotation.iv > 70.0) && (annotation.iv <= 90)) {
            bgColor = COLOR_VERYRARE;
        } else if((annotation.iv > 90) && (annotation.iv <= 100)) {
            bgColor = COLOR_ULTRARARE;
            // Wow pokemon is very strong !
            // Let's user know it :)
            [self addHoveredImage:[UIImage imageNamed:@"hot_pokemon"]];
        }
        
        [tagLabelView setLabelText:[NSString stringWithFormat:@"IV: %.f%%", annotation.iv]];
        [tagLabelView setBackgroundColor:bgColor];
        self.leftCalloutAccessoryView = tagLabelView;
    }
    
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
