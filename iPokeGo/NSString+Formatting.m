//
//  NSString+Formatting.m
//  iPokeGo
//
//  Created by Valeriy Pogoniev on 26/7/16.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "NSString+Formatting.h"

@implementation NSString (Formatting)

- (NSAttributedString *)outlinedAttributedString {
    NSDictionary *attributes = @{ NSStrokeColorAttributeName : [UIColor whiteColor],
                                  NSForegroundColorAttributeName : [UIColor blackColor],
                                  NSStrokeWidthAttributeName : [NSNumber numberWithFloat:-2.0]
                                  };
    return [[NSAttributedString alloc] initWithString:self attributes:attributes];
}

@end
