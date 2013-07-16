//
//  NewsListViewController.m
//  Bus Time
//
//  Created by venj on 13-1-6.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import "NewsListViewController.h"
#import "ASIHTTPRequest.h"
#import "AppDelegate.h"
#import "BusInfoCell.h"
#import "InfoPageViewController.h"

@interface NewsListViewController ()
@property (nonatomic, strong) ASIHTTPRequest *request;
@property (nonatomic, strong) NSMutableArray *newsList;
- (void)loadNews;
@end

@implementation NewsListViewController

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
	// Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"News", @"出行提示");
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStyleBordered handler:^(id sender) {
            [[AppDelegate shared] showLeftMenu];
        }];
    }
    [self loadNews];
}

- (void)loadNews {
    if ([self.request inProgress]) {
        return;
    }
    self.request = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://221.130.60.79:8080/Bus/sendinfo.action?length=all&index=0"]];
    __block NewsListViewController *blockSelf = self;
    __block ASIHTTPRequest *request_b = self.request;
    [self.request setRequestMethod:@"POST"];
    [self.request setStartedBlock:^{}];
    [self.request setCompletionBlock:^{
        NSString *responseString = [request_b responseString];
#if DEBUG
        //NSLog(@"%@", responseString);
#endif
        if (request_b.responseStatusCode == 200) {
            NSMutableArray *stringParts = [NSMutableArray arrayWithArray:[responseString split:@":;" rule:HFSplitRuleWhole]];
            NSInteger subArrayCount = [stringParts count] / 4;
            blockSelf.newsList = [[NSMutableArray alloc] initWithCapacity:subArrayCount];
            if ([stringParts count] % 4 != 0 && [[stringParts objectAtIndex:0] rangeOfString:@"月"].location == NSNotFound) {
                [stringParts removeObjectAtIndex:0];
            }
            for (NSInteger i = 0; i < subArrayCount; i++) {
                NSInteger sinceIndex = i * 4;
                NSArray *info = @[ stringParts[sinceIndex], stringParts[sinceIndex + 2], stringParts[sinceIndex + 3] ];
                [blockSelf.newsList addObject:info];
            }
            [blockSelf.tableView reloadData];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"提示") message:[NSString stringWithFormat:@"出行提示加载失败，服务器错误：HTTP %d。请稍后再试。", request_b.responseStatusCode] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
            [alert show];
        }
    }];
    [self.request setFailedBlock:^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Info", @"提示") message:NSLocalizedString(@"Network error, please retry later.", @"网络连接失败，请重试。") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"确定") otherButtonTitles:nil];
        [alert show];
    }];
    [self.request startAsynchronous];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [self.newsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NewsListCell";
    BusInfoCell *cell = (BusInfoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[BusInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSArray *info = [self.newsList objectAtIndex:indexPath.row];
    cell.textLabel.text = [info objectAtIndex:0];
    cell.detailTextLabel.text = [info objectAtIndex:1];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *info = [self.newsList objectAtIndex:indexPath.row];
    NSURL *URL = [NSURL URLWithString:[[info objectAtIndex:2] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    InfoPageViewController *webVC = [[InfoPageViewController alloc] initWithNibName:@"InfoPageViewController" bundle:nil];
    webVC.linkURL = URL;
    webVC.title = [self.tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self.navigationController pushViewController:webVC animated:YES];
    }
    else {
        UINavigationController *webNav = [[UINavigationController alloc] initWithRootViewController:webVC];
        webNav.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentModalViewController:webNav animated:YES];
    }
}

@end
