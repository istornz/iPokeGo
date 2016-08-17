//
//  TagButton.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 17/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "TagButton.h"

@implementation TagButton

-(instancetype)initWithText:(NSString *)text
{
    if(self = [self init])
    {
        self.titleLabel.textColor       = [UIColor whiteColor];
        self.titleLabel.textAlignment   = NSTextAlignmentCenter;
        self.layer.cornerRadius         = 5.0f;
        self.layer.masksToBounds        = YES;
        self.titleLabel.font            = [UIFont fontWithName:@"HelveticaNeue" size:15];
        self.backgroundColor            = [UIColor colorWithRed:0.75 green:0.19 blue:0.16 alpha:1.0];
        
        [self setTitle:text forState:UIControlStateNormal];
        [self sizeToFit];
        
        CGRect frameLbl         = self.frame;
        frameLbl.size.width     += 10;
        self.frame              = frameLbl;
    }
    
    return self;
}

@end
