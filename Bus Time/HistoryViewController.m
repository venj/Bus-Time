//
//  HistoryViewController.m
//  Bus Time
//
//  Created by venj on 13-1-4.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import "HistoryViewController.h"
#import "AppDelegate.h"
#import "UIBarButtonItem+Blocks.h"
#import "UserDataSource.h"
#import "History.h"
#import "BusDataSource.h"
#import "BusInfoCell.h"
#import "QueryResultViewController.h"

@interface HistoryViewController () {
    UIView *_emptyView;
}
@property (nonatomic, strong) NSArray *histories;
@property (nonatomic, strong, readonly) UIView *emptyView;
@end

@implementation HistoryViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.histories = [[UserDataSource shared] histories];
    if ([self.histories count] == 0) {
        self.tableView.backgroundView = self.emptyView;
        self.tableView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else {
        self.tableView.backgroundView = nil;
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Empty View
    self.title = @"查询历史";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStyleBordered handler:^(id sender) {
        [[AppDelegate shared] showLeftMenu];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleBordered handler:^(id sender) {
        [self changeEditingStatusAnimated:YES];
    }];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    [[AppDelegate shared] preloadMenus];
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
    return [self.histories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoritesCell";
    BusInfoCell *cell = (BusInfoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[BusInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    History *h = [self.histories objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@. %@", h.stationSequence, h.stationName];
    cell.detailTextLabel.text = h.segmentName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        History *h = [self.histories objectAtIndex:indexPath.row];
        [[UserDataSource shared] removeHistoryWithUserItem:h];
        self.histories = [[UserDataSource shared] histories];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    History *history = [self.histories objectAtIndex:indexPath.row];
    [[UserDataSource shared] addOrUpdateHistoryWithUserItem:history];
    QueryResultViewController *queryController;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        queryController = [[QueryResultViewController alloc] initWithStyle:UITableViewStyleGrouped];
        queryController.title = [NSString stringWithFormat:@"%@, %@", history.segmentName, history.stationName];
        queryController.station = nil;
        queryController.userItem = history;
        [self.navigationController pushViewController:queryController animated:YES];
    }
    else {
        queryController = [[AppDelegate shared] queryResultController];
        queryController.title = [NSString stringWithFormat:@"%@, %@", history.segmentName, history.stationName];
        queryController.station = nil;
        queryController.userItem = history;
        [queryController loadResult];
    }
}

#pragma mark - Helper Methods

- (UIView *)emptyView {
    if (_emptyView == nil) {
        CGRect tvFrame = self.tableView.frame;
        CGFloat navBarHeight = 44.0;
        CGFloat width = self.tableView.frame.size.width, height = 164.;
        CGFloat x = (tvFrame.size.width - width) / 2.0;
        CGFloat y = (tvFrame.size.height - height - navBarHeight) / 2.0;
        
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        UIImageView *starImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"history"]];
        starImageView.frame = CGRectMake(110., 0, 100, 100);
        [aView addSubview:starImageView];
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(60., 100., 200., 20.)];
        infoLabel.textAlignment = UITextAlignmentCenter;
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.text = @"您还没有任何查询纪录";
        infoLabel.font = [UIFont boldSystemFontOfSize:16];
        infoLabel.textColor = [UIColor colorWithRed:(0x4c / 255.) green:(0x56 / 255.) blue:(0x6c / 255.) alpha:1];
        infoLabel.shadowColor = [UIColor whiteColor];
        infoLabel.shadowOffset = CGSizeMake(0.0, 1.0);
        [aView addSubview:infoLabel];
        
        UIImage *originalImage = [UIImage imageNamed:@"find_bus_button"];
        UIImage *originalHighlightImage = [UIImage imageNamed:@"find_bus_hl_button"];
        UIImage *buttonImage, *buttonHighlightImage;
        if ([[UIImage class] respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            buttonImage = [originalImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        }
        else {
            buttonImage = [originalImage stretchableImageWithLeftCapWidth:8 topCapHeight:0];
        }
        if ([[UIImage class] respondsToSelector:@selector(resizableImageWithCapInsets:)]) {
            buttonHighlightImage = [originalHighlightImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        }
        else {
            buttonHighlightImage = [originalHighlightImage stretchableImageWithLeftCapWidth:8 topCapHeight:0];
        }
        
        UIButton *addFavoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addFavoriteButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [addFavoriteButton setBackgroundImage:buttonHighlightImage forState:UIControlStateHighlighted];
        [addFavoriteButton setTitle:@"开始查询" forState:UIControlStateNormal];
        addFavoriteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        addFavoriteButton.titleLabel.shadowColor = [UIColor grayColor];
        addFavoriteButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        addFavoriteButton.frame = CGRectMake(60, 128, 200, 36);
        [addFavoriteButton addTarget:self action:@selector(showBusList:) forControlEvents:UIControlEventTouchUpInside];
        [aView addSubview:addFavoriteButton];
        
        aView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.tableView.frame.size.width, self.tableView.frame.size.height - navBarHeight)];
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [containerView addSubview:aView];
        return containerView;
    }
    return _emptyView;
}

- (void)showBusList:(id)sender {
    [[AppDelegate shared] showLeftMenu];
}

- (void)changeEditingStatusAnimated:(BOOL)animated {
    if ([self.tableView isEditing]) {
        self.navigationItem.rightBarButtonItem.title = @"编辑";
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
        [self.tableView setEditing:NO animated:animated];
    }
    else {
        self.navigationItem.rightBarButtonItem.title = @"完成";
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
        [self.tableView setEditing:YES animated:animated];
    }
}
@end
