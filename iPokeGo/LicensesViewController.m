//
//  LicensesViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 15/08/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "LicensesViewController.h"

@interface LicensesViewController ()

@end

@implementation LicensesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *htmlFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"licenses" ofType:@"html"] isDirectory:NO];
    [self.licensesWebView loadRequest:[NSURLRequest requestWithURL:htmlFile]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
