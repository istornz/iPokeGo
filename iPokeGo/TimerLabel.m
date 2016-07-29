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

- (void)setDate:(NSDate*)date {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    self.expiryDate = date;
    [self setTimeInterval:[self.expiryDate timeIntervalSinceNow]];
}

- (void)timerFired {
    NSTimeInterval expiredIn = [self.expiryDate timeIntervalSinceNow];
    if (expiredIn > 0) {
        [self setTimeInterval:expiredIn];
    } else {
        [self.timer invalidate];
    }
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    NSInteger integerValue = (NSInteger)timeInterval;
    uint8_t minutes = integerValue / 60;
    uint8_t seconds = integerValue % 60;
    self.attributedText = [NSString stringWithFormat:@"%d:%02d", minutes, seconds].outlinedAttributedString;
}

@end
