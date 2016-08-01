//
//  TimeLabel.m
//  iPokeGo
//
//  Created by Valeriy Pogoniev on 26/7/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "TimeLabel.h"
#import "NSString+Formatting.h"

@implementation TimeLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont boldSystemFontOfSize:10.0];
        self.textAlignment = NSTextAlignmentLeft;
    }
    return self;
}

- (void)setDate:(NSDate*)date
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
    });
    
    self.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
}

@end
