//
//  FavoritesViewController.m
//  Bus Time
//
//  Created by venj on 12-12-21.
//  Copyright (c) 2012年 venj. All rights reserved.
//

#import "FavoritesViewController.h"
#import "AppDelegate.h"

@interface FavoritesViewController () {
    UIView *_emptyView;
}
@property (nonatomic, strong) NSArray *favorites;
@property (nonatomic, strong, readonly) UIView *emptyView;
@end

@implementation FavoritesViewController

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Empty View
    self.tableView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    if ([self.favorites count] == 0) {
        self.tableView.backgroundView = self.emptyView;
    }
    else {
        self.tableView.backgroundView = nil;
    }
    self.title = @"收藏夹";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon"] style:UIBarButtonItemStyleBordered handler:^(id sender) {
        [[AppDelegate shared] showLeftMenu];
    }];
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
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoritesCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Helper Methods

- (UIView *)emptyView {
    if (_emptyView == nil) {
        CGRect tvFrame = self.tableView.frame;
        CGFloat navBarHeight = 44.0;
        CGFloat width = self.tableView.frame.size.width, height = 164.;
        CGFloat x = (tvFrame.size.width - width) / 2.0;
        CGFloat y = (tvFrame.size.height - height) / 2.0 - 60;
        
        UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        UIImageView *starImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"star"]];
        starImageView.frame = CGRectMake(110., 0, 100, 100);
        [aView addSubview:starImageView];
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(60., 101., 200., 20.)];
        infoLabel.textAlignment = UITextAlignmentCenter;
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.text = @"您还没有收藏任何站点";
        infoLabel.font = [UIFont systemFontOfSize:15];
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
        [addFavoriteButton setTitle:@"查找一个公交站" forState:UIControlStateNormal];
        addFavoriteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        addFavoriteButton.titleLabel.shadowColor = [UIColor grayColor];
        addFavoriteButton.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
        addFavoriteButton.frame = CGRectMake(60, 129, 200, 36);
        [addFavoriteButton addTarget:self action:@selector(showBusList:) forControlEvents:UIControlEventTouchUpInside];
        [aView addSubview:addFavoriteButton];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.tableView.frame.size.width, self.tableView.frame.size.height - navBarHeight)];
        [containerView addSubview:aView];
        return containerView;
    }
    return _emptyView;
}

- (void)showBusList:(id)sender {
    [[AppDelegate shared] showLeftMenu];
}

@end
