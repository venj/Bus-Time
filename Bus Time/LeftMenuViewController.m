//
//  LeftMenuViewController.m
//  Bus Time
//
//  Created by venj on 12-12-19.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "PPRevealSideViewController.h"
#import "AppDelegate.h"
#import "LeftMenuCell.h"

static NSString *menuTitles[] = {@"查询历史", @"收藏夹", @"公交查询", @"附近的公交站", @"设置"};

@interface LeftMenuViewController ()

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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
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
    return [[[AppDelegate shared] menuViewControllers] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LeftMenuCell";
    LeftMenuCell *cell = (LeftMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[LeftMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = menuTitles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.backgroundColor = [UIColor clearColor];
    UIView *view = [[UIView alloc] initWithFrame:cell.frame];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_cell_bg"]];
    cell.backgroundView = view;
    
    UIView *hlView = [[UIView alloc] initWithFrame:cell.frame];
    hlView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"menu_cell_hl_bg"]];
    cell.selectedBackgroundView = hlView;
    
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
