//
//  LeftMenuViewController.m
//  Bus Time
//
//  Created by venj on 12-12-19.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "LeftMenuViewController.h"
#import <PPRevealSideViewController/PPRevealSideViewController.h>
#import "AppDelegate.h"
#import "LeftMenuCell.h"

static NSString *imageNames[] = {@"menu_history", @"menu_star", @"menu_bus", @"menu_search", @"menu_position", @"menu_info", @"menu_gear"};

@interface LeftMenuViewController () {
    NSArray *__menuTitles;
}

@end

@implementation LeftMenuViewController

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
    __menuTitles = @[NSLocalizedString(@"History", @"查询历史"), NSLocalizedString(@"Favorites", @"收藏夹"), NSLocalizedString(@"Buses", @"公交路线"), NSLocalizedString(@"Search", @"站名搜索"), NSLocalizedString(@"Nearby", @"附近站点"), NSLocalizedString(@"News", @"出行提示"),
        NSLocalizedString(@"Settings", @"设置")];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if ([[AppDelegate shared] deviceSystemMajorVersion] > 6) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20.)];
        header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        header.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = header;
        self.tableView.backgroundColor = [UIColor colorWithRed:248./255. green:248./255. blue:248./255. alpha:1];
    }
    else {
        self.tableView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
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
    return [[[AppDelegate shared] menuViewControllers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LeftMenuCell";
    LeftMenuCell *cell = (LeftMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[LeftMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = __menuTitles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:imageNames[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[AppDelegate shared] deviceSystemMajorVersion] < 7) {
        cell.textLabel.backgroundColor = [UIColor clearColor];
        UIView *view = [[UIView alloc] initWithFrame:cell.frame];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_cell_bg"]];
        cell.backgroundView = view;
        
        UIView *hlView = [[UIView alloc] initWithFrame:cell.frame];
        hlView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_cell_hl_bg"]];
        cell.selectedBackgroundView = hlView;
        
    }
    else {
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
            UIView *hlView = [[UIView alloc] initWithFrame:cell.frame];
            hlView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
            cell.selectedBackgroundView = hlView;
        }
    }
        
    if (indexPath.row == [[AppDelegate shared].menuViewControllers indexOfObject:[AppDelegate shared].revealController.rootViewController])
        cell.selected = YES;
    else
        cell.selected = NO;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[AppDelegate shared] popViewControllerAtIndex:indexPath.row];
}

@end
