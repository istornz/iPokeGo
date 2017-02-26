//
//  ThemesTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 26/02/2017.
//  Copyright © 2017 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"
#import "ThemesTableViewCell.h"
#import "AppDelegate.h"
#import "UIApplication+M13ProgressSuite.h"
#import "ZipArchive.h"

@interface ThemesTableViewController : UITableViewController

@property(strong, nonatomic) NSArray *themeArray;
@property(weak, nonatomic) IBOutlet UILabel *footerLabel;

-(IBAction)downloadNewThemeAction:(id)sender;

@end
