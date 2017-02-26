//
//  ThemesTableViewCell.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 26/02/2017.
//  Copyright © 2017 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThemesTableViewCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UIImageView *themeIconImageView;
@property(weak, nonatomic) IBOutlet UILabel *nameLabel;
@property(weak, nonatomic) IBOutlet UILabel *describeLabel;

@end
