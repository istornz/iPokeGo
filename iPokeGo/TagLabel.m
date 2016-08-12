//
//  TagLabel.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 12/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "TagLabel.h"

@implementation TagLabel

- (instancetype)init {
    if (self = [super init]) {
        self.textColor              = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.layer.cornerRadius     = 5.0f;
        self.layer.masksToBounds    = YES;
        self.font                   = [UIFont fontWithName:@"HelveticaNeue" size:15];
    }
    return self;
}

-(void)setLabelText:(NSString *)text
{
    self.text = text;
    [self sizeToFit];
    
    CGRect frameLbl = self.frame;
    frameLbl.size.height += 10;
    frameLbl.size.width += 10;
    self.frame = frameLbl;
}

@end
