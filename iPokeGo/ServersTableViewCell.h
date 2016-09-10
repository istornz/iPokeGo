//
//  ServersTableViewCell.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 04/09/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServersTableViewCell : UITableViewCell

@property(weak, nonatomic) IBOutlet UILabel *serverNameLabel;
@property(weak, nonatomic) IBOutlet UILabel *serverAddrLabel;

@end
