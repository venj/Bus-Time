//
//  SettingsViewController.m
//  BusTime
//
//  Created by 朱 文杰 on 12-8-21.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "SettingsViewController.h"
#import "Common.h"
#import "cl_BlockHead.h"

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
    self.title = @"设置";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone handler:^(id sender) {
        [self dismissModalViewControllerAnimated:YES];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 1;
    }
    else {
        return 1;
    }
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
        cell.textLabel.text = @"服务器地址";
        cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:kServerAddressStorage];
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = @"清空缓存和设置";
    }
    else {
        cell.textLabel.text = @"版本号";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ build %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"基本设置";
    }
    else if (section == 1) {
        return @"高级设置";
    }
    else {
        return @"版本信息";
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return @"修改本设置可能导致程序无法使用！你通常不需要修改这个设置，除非服务器地址发生了变化。如果你不小心修改了这个设置，请使用“清空缓存和设置”，并重新启动程序。";
    }
    else if (section == 1){
        return @"你通常不需要使用本设置。你可以使用这个设置项来恢复程序的默认设置。";
    }
    else {
        return @"声明：本程序的开发人员和无锡公交公司没有任何关系，开发本程序纯属个人兴趣爱好。所有公交车和到站信息均来自无锡公交公司网站，程序开发人员不对信息的正确性负责。\n无锡公交公司随时可能改变数据呈现格式，因此，本程序的开发人员也不保证本程序能够长期有效。";
        
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            __block UIAlertView *alertView;
            alertView = [[UIAlertView alloc] initWithTitle:@"请输入服务器地址" message:@"输入的地址必须包含http://" completionBlock:^(NSUInteger buttonIndex) {
                if (buttonIndex != [alertView cancelButtonIndex]) {
                    [defaults setObject:[alertView textFieldAtIndex:0].text forKey:kServerAddressStorage];
                    [defaults synchronize];
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField *tf = [alertView textFieldAtIndex:0];
            tf.clearButtonMode = UITextFieldViewModeAlways;
            tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            NSString *str = [defaults objectForKey:kServerAddressStorage];
            if (str == nil)
                str = SERVER_ADDRESS;
            tf.text = str;
            [alertView show];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [[[UIAlertView alloc] initWithTitle:@"清空缓存和设置" message:@"即将清空程序缓存和程序设置，是否继续？" completionBlock:^(NSUInteger buttonIndex) {
                if (buttonIndex != 0) {
                    [defaults removeObjectForKey:kServerAddressStorage];
                    [defaults removeObjectForKey:kBusStorage];
                    [defaults removeObjectForKey:kBusFormPartitialStorage];
                    [defaults synchronize];
                }
            } cancelButtonTitle:@"取消" otherButtonTitles:@"清空", nil] show];
        }
    }
}

@end
