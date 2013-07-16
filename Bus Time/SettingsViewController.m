//
//  SettingsViewController.m
//  BusTime
//
//  Created by 朱 文杰 on 12-8-21.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "InfoPageViewController.h"
#import "BusDataSource.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Settings", @"设置");
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStyleBordered handler:^(id sender) {
            [[AppDelegate shared] showLeftMenu];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 5;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Version", @"版本号");
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ build %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"DB Version", @"数据库版本");
            cell.detailTextLabel.text = [BusDataSource busDataBaseVersion];
            
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"Disclaimer", @"免责声明");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Copyright", @"版权协议");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Acknowledgements", @"致谢");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"About", @"关于本程序");
    }
    return @"";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row < 2) {
            return;
        }
        else {
            NSArray *files = @[@"disclaimer", @"copyright", @"acknowledgements"];
            NSString *filePath = [[NSBundle mainBundle] pathForResource:files[indexPath.row - 2] ofType:@"html"];
            NSURL *fileURL = [NSURL fileURLWithPath:filePath];
            InfoPageViewController *webVC = [[InfoPageViewController alloc] initWithNibName:@"InfoPageViewController" bundle:nil];
            webVC.linkURL = fileURL;
            webVC.title = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                [self.navigationController pushViewController:webVC animated:YES];
            }
            else {
                UINavigationController *webNav = [[UINavigationController alloc] initWithRootViewController:webVC];
                webNav.modalPresentationStyle = UIModalPresentationFormSheet;
                [self presentModalViewController:webNav animated:YES];
            }
        }
    }
}

@end
