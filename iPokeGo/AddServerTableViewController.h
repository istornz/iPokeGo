//
//  AddServerTableViewController.h
//  iPokeGo
//
//  Created by Dimitri Dessus on 04/09/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "global.h"

@interface AddServerTableViewController : UITableViewController <UITextFieldDelegate>

@property(weak, nonatomic) IBOutlet UIBarButtonItem *closeButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property(weak, nonatomic) IBOutlet UIImageView *serverTypeImageView;
@property(weak, nonatomic) IBOutlet UILabel *serverTypeLabel;
@property(weak, nonatomic) IBOutlet UILabel *serverTypeTextLabel;

@property(weak, nonatomic) IBOutlet UIImageView *serverNameImageView;
@property(weak, nonatomic) IBOutlet UILabel *serverNameLabel;
@property(weak, nonatomic) IBOutlet UITextField *serverNameField;

@property(weak, nonatomic) IBOutlet UIImageView *serverImageView;
@property(weak, nonatomic) IBOutlet UILabel *serverLabel;
@property(weak, nonatomic) IBOutlet UITextField *serverTextField;

@property(weak, nonatomic) IBOutlet UIImageView *usernameImageView;
@property(weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property(weak, nonatomic) IBOutlet UITextField *usernameField;

@property(weak, nonatomic) IBOutlet UIImageView *passwordImageView;
@property(weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property(weak, nonatomic) IBOutlet UITextField *passwordField;

-(IBAction)doneAction:(id)sender;
-(IBAction)cancelAction:(id)sender;

@end
