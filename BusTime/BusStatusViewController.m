//
//  BusStatusViewController.m
//  BusTime
//
//  Created by 朱 文杰 on 12-8-20.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "BusStatusViewController.h"
#import "cl_BlockHead.h"
#import "ASIFormDataRequest.h"
#import "AppDelegate.h"
#import "Common.h"
#import "WXBusParser.h"

@interface BusStatusViewController ()

@end

@implementation BusStatusViewController

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
    self.title = [[NSString alloc] initWithFormat:@"公交“%@”状态", self.currentBusName];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(showBusStatus:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    else if ([self.nextBuses isKindOfClass:NSClassFromString(@"NSString")]) {
        return 0;
    }
    else {
        return [self.nextBuses count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BusStatusTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.text = self.currentStationName;
        //cell.detailTextLabel.text = @"";
    }
    else {
        NSArray *bus = [self.nextBuses objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"于%@到达“%@”", [bus objectAtIndex:1], [bus objectAtIndex:0]];
        cell.textLabel.font = [UIFont systemFontOfSize:17];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"距离本站还有%@站", [bus objectAtIndex:2]];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.18f green:0.32f blue:0.52f alpha:1.00f];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"当前公交站";
    }
    return @"离本站最近的公交车";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSLocale *currentLocale = [NSLocale currentLocale];
    [dateFormatter setLocale:currentLocale];
    NSString *timeString = [NSString stringWithFormat:@"最近更新于：%@", [dateFormatter stringFromDate:[NSDate date]]];
    
    if (section == 0) {
        return nil;
    }
    else if ([self.nextBuses isKindOfClass:NSClassFromString(@"NSString")]) {
        return [NSString stringWithFormat:@"%@\n%@", self.nextBuses, timeString];
    }
    else {
        return timeString;
    }
}

#pragma mark - Action 

// 查看公交车状态
- (void)showBusStatus:(id)sender {
    NSDictionary *formDict = [[NSUserDefaults standardUserDefaults] objectForKey:kBusStatusFormStorage];
    NSString *serverAddress = [[NSUserDefaults standardUserDefaults] objectForKey:kServerAddressStorage];
    [[AppDelegate shared] showHUDLoadingInView:self.view withMessage:@"公交位置加载中..."];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[[NSURL alloc] initWithString:serverAddress]];
    for (id key in [formDict allKeys]) {
        [request setPostValue:[formDict objectForKey:key] forKey:key];
    }
    
    __block ASIFormDataRequest *request_b = request;
    [request setCompletionBlock:^{
        [[AppDelegate shared] hideHUD];
        NSData *responseData = [request_b responseData];
        WXBusParser *parser = [[WXBusParser alloc] initWithData:responseData];
        [parser parse];
        
        if ([parser.nextBuses isKindOfClass:NSClassFromString(@"NSString")]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:parser.nextBuses delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            self.nextBuses = parser.nextBuses;
            [self.tableView reloadData];
        }
        else if (parser.nextBuses == nil || [parser.nextBuses count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未知错误" message:@"发生未知错误，请联系开发人员处理这个问题。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            self.nextBuses = nil;
            [self.tableView reloadData];
        }
        else {
            self.nextBuses = parser.nextBuses;
            [self.tableView reloadData];
        }
    }];
    
    [request setFailedBlock:^{
        [[AppDelegate shared] hideHUDWithMessage:@"请求超时，请重试！"];
    }];
    
    [request startAsynchronous];
}

@end
