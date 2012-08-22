//
//  BusStatusViewController.m
//  BusTime
//
//  Created by 朱 文杰 on 12-8-20.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "BusStatusViewController.h"

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
    
    self.title = @"公交车状态";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return [self.nextBuses count];
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

@end
