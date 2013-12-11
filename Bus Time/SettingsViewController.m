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
#import <MBProgressHUD/MBProgressHUD.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>

#define DoNotNotifyDBVersion @"kDoNotNotifyDBVersion"

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
        if (indexPath.row == 0) {
            [[AppDelegate shared] checkAppVersion];
        }
        else if (indexPath.row == 1) {
            [self checkDBVersion]; // Check, download and update.
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

#pragma mark - Update Database

// Check and download
- (void)checkDBVersion {
    ASIHTTPRequest *versionRequest = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@version_db.txt", SERVER_ADDRESS]]];
    ASIHTTPRequest *request_b = versionRequest;
    //__weak BusDataSource *weakSelf = self;
    //网络请求成功
    [versionRequest setCompletionBlock:^{
        NSString *versionString = [request_b responseString];
        if (![[versionString strip] isEqualToString:[BusDataSource busDataBaseVersion]] && ![[[NSUserDefaults standardUserDefaults] objectForKey:DoNotNotifyDBVersion] isEqualToString:versionString]) {
            [UIAlertView showAlertViewWithTitle:NSLocalizedString(@"Database Update", @"数据库更新") message:NSLocalizedString(@"New bus database found, do you want to update?", @"公交车数据库已经更新。是否开始下载？") cancelButtonTitle:NSLocalizedString(@"Later", @"以后再说") otherButtonTitles:@[NSLocalizedString(@"Update Now", @"立刻升级"), NSLocalizedString(@"Never", @"不再提示")] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == [alertView cancelButtonIndex]) {
                    return;
                }
                else if (buttonIndex == [alertView firstOtherButtonIndex]) {
                    //升级
                    [self downloadDatabaseFile];
                }
                else if (buttonIndex == [alertView firstOtherButtonIndex] + 1) {
                    [[NSUserDefaults standardUserDefaults] setObject:versionString forKey:DoNotNotifyDBVersion]; //不再提示
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }];
        }
        else {
            // Already the latest version of db.
        }
    }];
    [versionRequest startAsynchronous];
}

// Download
- (void)downloadDatabaseFile {
    //TODO: Download file.
    [self replaceDatabaseFile];
}

- (void)replaceDatabaseFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = paths[0];
    NSString *downloadedDatabaseFile = [cacheDirectory stringByAppendingPathComponent:@"wuxitraffic.db"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:downloadedDatabaseFile isDirectory:NO]) {
        [BusDataSource updateDatabaseFileWithFileAtPath:downloadedDatabaseFile];
        [self.tableView reloadData];
    }
}

@end
