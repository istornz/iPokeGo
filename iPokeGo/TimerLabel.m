//
//  TimerLabel.m
//  iPokeGo
//
//  Created by Valeriy Pogoniev on 26/7/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "TimerLabel.h"
#import "NSString+Formatting.h"

@interface TimerLabel()
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSDate *expiryDate;
@end

@implementation TimerLabel

NSString * const TimerLabelUpdateNotification = @"Poke.TimerLabelUpdateNotification";

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

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerFired) name:TimerLabelUpdateNotification object:nil];
}

- (void)setDate:(NSDate*)date {
    self.expiryDate = date;
    [self setTimeInterval:[self.expiryDate timeIntervalSinceNow]];
}

- (void)timerFired {
    NSTimeInterval expiredIn = [self.expiryDate timeIntervalSinceNow];
    if (expiredIn > 0) {
        [self setTimeInterval:expiredIn];
    }
}

- (void)setHidden:(BOOL)hidden
{
    super.hidden = hidden;
    if (hidden) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TimerLabelUpdateNotification object:nil];
    } else {
        [self setup];
        NSTimeInterval expiredIn = [self.expiryDate timeIntervalSinceNow];
        [self setTimeInterval:expiredIn];
    }
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    NSInteger integerValue = (NSInteger)timeInterval;
    uint8_t minutes = integerValue / 60;
    uint8_t seconds = integerValue % 60;
    if (timeInterval > 0) {
        self.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    } else {
        self.text = @"-";
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
