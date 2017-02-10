//
//  NotificationsSettingsTableViewController.m
//  iPokeGo
//
//  Created by Dimitri Dessus on 25/07/2016.
//  Copyright © 2016 Dimitri Dessus. All rights reserved.
//

#import "NotificationsSettingsTableViewController.h"

#define kCommonRangeCell        1
#define kCommonRangePicker      2
#define kFavoriteRangeCell      4
#define kFavoriteRangePicker    5
#define kIVRangeCell            9
#define kIVRangePicker          10

@interface NotificationsSettingsTableViewController ()

@property (assign) NSInteger pickerCellRowHeight;
@property (nonatomic, strong) NSArray *rangePickerRanges;
@property (nonatomic, strong) NSArray *ivPickerRanges;
@property (nonatomic, strong) NSIndexPath *pickerIndexPath;

@end

@implementation NotificationsSettingsTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.rangePickerRanges      = @[@0, @100, @250, @500, @750, @1000, @1500, @2000, @2500, @5000, @10000, @25000];
    self.ivPickerRanges         = @[@50, @60, @70, @80, @90, @100];
    self.pickerCellRowHeight    = 150;
    
    self.commonRangePicker.delegate = self;
    self.commonRangePicker.dataSource = self;
    self.favoriteRangePicker.delegate = self;
    self.favoriteRangePicker.dataSource = self;
    self.ivRangePicker.delegate = self;
    self.ivRangePicker.dataSource = self;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.tableView.tableFooterView = footerView;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.normalNotificationSwitch.on = [prefs boolForKey:@"norm_notification"];
    self.favoriteNotificationSwitch.on = [prefs boolForKey:@"fav_notification"];
    self.vibrationSwitch.on = [prefs boolForKey:@"vibration"];
    self.rangeSwitch.on = [prefs boolForKey:@"only_notify_in_range"];
    self.ivSwitch.on = [prefs boolForKey:@"only_notify_for_iv"];
    
    self.commonRangeLabel.text = [NSString stringWithFormat:@"%dm", (int)[prefs integerForKey:@"common_notification_range"]];
    self.favoriteRangeLabel.text = [NSString stringWithFormat:@"%dm", (int)[prefs integerForKey:@"favorite_notification_range"]];
    
    int ivRange = (int)[prefs integerForKey:@"iv_notification_range"];
    if(ivRange < 100)
        self.ivRangeLabel.text = [NSString stringWithFormat:@">= %d %%", ivRange];
    else
        self.ivRangeLabel.text = [NSString stringWithFormat:@"= %d %%", ivRange];
    
    [self.commonRangePicker selectRow:[self rangePickerRowForValue:(int)[prefs integerForKey:@"common_notification_range"]] inComponent:0 animated:YES];
    [self.favoriteRangePicker selectRow:[self rangePickerRowForValue:(int)[prefs integerForKey:@"favorite_notification_range"]] inComponent:0 animated:YES];
    [self.ivRangePicker selectRow:[self ivPickerRowForValue:(int)[prefs integerForKey:@"iv_notification_range"]] inComponent:0 animated:YES];
}

-(int)rangePickerRowForValue:(int)value
{
    if(self.rangePickerRanges.count) {
        int index;
        for (index = 0; index <= self.rangePickerRanges.count; index++) {
            if ([[self.rangePickerRanges objectAtIndex:index] intValue] == value) {
                return index;
            }
        }
        
        return 0;
    } else {
        return 0;
    }
}

-(int)ivPickerRowForValue:(int)value
{
    if(self.ivPickerRanges.count) {
        int index;
        for (index = 0; index <= self.ivPickerRanges.count; index++) {
            if ([[self.ivPickerRanges objectAtIndex:index] intValue] == value) {
                return index;
            }
        }
        
        return 0;
    } else {
        return 0;
    }
}

-(IBAction)switchAction:(UISwitch *)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (sender == self.normalNotificationSwitch) {
        [prefs setBool:self.normalNotificationSwitch.on forKey:@"norm_notification"];
    } else if (sender == self.favoriteNotificationSwitch) {
        [prefs setBool:self.favoriteNotificationSwitch.on forKey:@"fav_notification"];
    } else if (sender == self.vibrationSwitch) {
        [prefs setBool:self.vibrationSwitch.on forKey:@"vibration"];
    } else if (sender == self.rangeSwitch) {
        [prefs setBool:self.rangeSwitch.on forKey:@"only_notify_in_range"];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    } else if (sender == self.ivSwitch) {
        [prefs setBool:self.ivSwitch.on forKey:@"only_notify_for_iv"];
        self.pickerIndexPath = nil;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == kCommonRangeCell || indexPath.row == kFavoriteRangeCell || indexPath.row == kIVRangeCell) {
        if(!self.pickerIndexPath || self.pickerIndexPath.row - 1 != indexPath.row) {
            switch (indexPath.row) {
                case kCommonRangeCell:
                    self.pickerIndexPath = [NSIndexPath indexPathForRow:kCommonRangePicker inSection:0];
                    break;
                case kFavoriteRangeCell:
                    self.pickerIndexPath = [NSIndexPath indexPathForRow:kFavoriteRangePicker inSection:0];
                    break;
                case kIVRangeCell:
                    self.pickerIndexPath = [NSIndexPath indexPathForRow:kIVRangePicker inSection:0];
                    break;
            }
        } else {
            self.pickerIndexPath = nil;
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView beginUpdates];
        [tableView endUpdates];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case kCommonRangeCell:
            if(!self.rangeSwitch.on) {
                return 0;
            }
            break;
        case kCommonRangePicker:
            if(indexPath == self.pickerIndexPath) {
                return self.pickerCellRowHeight;
            } else {
                return 0;
            }
            break;
        case kFavoriteRangeCell:
            if(!self.rangeSwitch.on) {
                return 0;
            }
            break;
        case kFavoriteRangePicker:
            if(indexPath == self.pickerIndexPath) {
                return self.pickerCellRowHeight;
            } else {
                return 0;
            }
        case kIVRangeCell:
            if(!self.ivSwitch.on) {
                return 0;
            }
            break;
        case kIVRangePicker:
            if(indexPath == self.pickerIndexPath) {
                return self.pickerCellRowHeight;
            } else {
                return 0;
            }
            break;
    }
    
    return self.tableView.rowHeight;
}

#pragma mark - UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == self.ivRangePicker)
        return self.ivPickerRanges.count;
    else
        return self.rangePickerRanges.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == self.ivRangePicker)
    {
        int value = [[self.ivPickerRanges objectAtIndex:row] intValue];
        
        if(value < 100) {
            return [NSString stringWithFormat:@">= %d%%", value];
        } else {
            return @"= 100%";
        }
    }
    
    int value = [[self.rangePickerRanges objectAtIndex:row] intValue];
        
    if(value) {
        return [NSString stringWithFormat:@"%dm", value];
    } else {
        return @"∞m";
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int rangeRowInt = [[self.rangePickerRanges objectAtIndex:row] intValue];
    int ivRowInt = [[self.ivPickerRanges objectAtIndex:row] intValue];
    if(pickerView == self.commonRangePicker) {
        [prefs setInteger:rangeRowInt forKey:@"common_notification_range"];
        self.commonRangeLabel.text = [NSString stringWithFormat:@"%dm", rangeRowInt];
    } else if(pickerView == self.favoriteRangePicker) {
        [prefs setInteger:rangeRowInt forKey:@"favorite_notification_range"];
        self.favoriteRangeLabel.text = [NSString stringWithFormat:@"%dm", rangeRowInt];
    } else if(pickerView == self.ivRangePicker) {
        [prefs setInteger:ivRowInt forKey:@"iv_notification_range"];
        
        if(ivRowInt < 100)
            self.ivRangeLabel.text = [NSString stringWithFormat:@">= %d %%", ivRowInt];
        else
            self.ivRangeLabel.text = [NSString stringWithFormat:@"= %d %%", ivRowInt];
    }
}

@end
