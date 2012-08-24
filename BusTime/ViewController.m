//
//  ViewController.m
//  BusTime
//
//  Created by 朱 文杰 on 12-8-20.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import "ViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "cl_BlockHead.h"
#import "TFHpple.h"
#import "HandyFoundation.h"
#import "BusStatusViewController.h"
#import "Common.h"
#import "SettingsViewController.h"
#import "WXBusParser.h"
#import "AppDelegate.h"

@interface ViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *busRoutes;
@property (strong, nonatomic) NSArray *directionRoutes;
@property (strong, nonatomic) NSArray *stations;
@property (strong, nonatomic) NSMutableDictionary *formDict;
@property (assign, nonatomic) BusSelectStep currentStep;
@property (weak, nonatomic) IBOutlet UITextField *busField;
@property (weak, nonatomic) IBOutlet UITextField *directionField;
@property (weak, nonatomic) IBOutlet UITextField *stationField;
@property (weak, nonatomic) IBOutlet UIButton *busSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *directionSelectButton;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSString *serverAddress;
@end

@implementation ViewController

#pragma mark - View Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"公交实时查询";
    self.defaults = [NSUserDefaults standardUserDefaults];
    [self loadServerAddress];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh handler:^(id sender) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"通常你不需要重新载入公交列表，除非公交公司有线路调整。\n\n你真的需要重新载入公交列表吗？" completionBlock:^(NSUInteger buttonIndex) {
            if (buttonIndex != 0) {
                self.currentStep = BusSelectStepSelectBus;
                [self loadBusRoutesNeedRefresh:YES];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定"] show];
    }];
    
    if (!self.busRoutes) {
        self.busRoutes = [[NSArray alloc] init];
    }
    if (!self.directionRoutes) {
        self.directionRoutes = [[NSArray alloc] init];
    }
    if (!self.stations) {
        self.stations = [[NSArray alloc] init];
    }
    if (!self.formDict) {
        self.formDict = [[NSMutableDictionary alloc] init];
    }
    self.currentStep = BusSelectStepSelectBus;
#if TARGET_IS_DEBUG
    [self loadBusRoutesNeedRefresh:NO];
#else
    [self loadBusRoutesNeedRefresh:NO];
#endif

#if TARGET_IS_BETA
    BOOL needShowPrompt;
    NSInteger counter = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LaunchCounter"] integerValue];
    if (counter % 5 == 0) {
        needShowPrompt = YES;
    }
    else {
        needShowPrompt = NO;
    }
    if (needShowPrompt) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"感谢您使用无锡公交查询测试版。\n\n如果您遇到什么程序问题，请Email给ersaclarke[at]gmail.com。\n邮件标题请使用：“无锡公交查询问题反馈”。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@(counter + 1) forKey:@"LaunchCounter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
#endif
    
}

- (void)loadServerAddress {
    self.defaults = [NSUserDefaults standardUserDefaults];
    NSString *serverAddress = [self.defaults objectForKey:kServerAddressStorage];
    if (serverAddress == nil || [serverAddress isBlank]) {
        serverAddress = SERVER_ADDRESS;
        [self.defaults setObject:SERVER_ADDRESS forKey:kServerAddressStorage];
        [self.defaults synchronize];
    }
    self.serverAddress = serverAddress;
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadServerAddress];
    
    if ([self.defaults objectForKey:kBusStorage] == nil) {
        [self loadBusRoutesNeedRefresh:YES];
    }
}

- (void)viewDidUnload
{
    [self setPickerView:nil];
    [self setBusField:nil];
    [self setDirectionField:nil];
    [self setStationField:nil];
    [self setBusSelectButton:nil];
    [self setDirectionSelectButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - UI related actions

- (void)showSettings:(id)sender {
    SettingsViewController *settingVC = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingVC];
    nav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentModalViewController:nav animated:YES];
}

- (IBAction)selectItem:(id)sender {
    switch ([sender tag]) {
        case 1: {
            if ([self.pickerView numberOfRowsInComponent:0] == 1) {
                [self loadBusRoutesNeedRefresh:YES];
            }
            else {
                self.currentStep = BusSelectStepSelectBus;
                self.busField.text = @"";
                self.stationField.text = @"";
                self.directionField.text = @"";
                self.stations = nil;
                self.directionRoutes = nil;
                self.directionSelectButton.hidden = YES;
                [self.pickerView reloadComponent:0];
                [self.pickerView selectRow:0 inComponent:0 animated:YES];
            }
            break;
        }
        case 2: {
            self.currentStep = BusSelectStepSelectDirection;
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择行车方向" completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                [self.formDict setObject:[[self.directionRoutes objectAtIndex:(buttonIndex)] objectForKey:kBusID] forKey:@"ddlSegment"];
                self.directionField.text = [[self.directionRoutes objectAtIndex:(buttonIndex)] objectForKey:kBusName];
                [self loadStationsForIndex:buttonIndex];
            } cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            for (NSDictionary *dict in self.directionRoutes) {
                [sheet addButtonWithTitle:[dict objectForKey:kBusName]];
            }
            
            [sheet showInView:self.view];
            break;
        }
        default:
            break;
    }
}

#pragma mark - PickerView DataSource and Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.currentStep == BusSelectStepSelectStation) {
        return [self.stations count];
    }
    else {
        return [self.busRoutes count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.currentStep == BusSelectStepSelectStation) {
        return [[self.stations objectAtIndex:row] objectForKey:kStationName];
    }
    else {
        return [[self.busRoutes objectAtIndex:row] objectForKey:kBusName];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.currentStep == BusSelectStepSelectBus) {
        if (row == 0) {
            return;
        }
        [self.formDict setObject:[[self.busRoutes objectAtIndex:row] objectForKey:kBusID] forKey:@"ddlRoute"];
        self.busField.text = [[self.busRoutes objectAtIndex:row] objectForKey:kBusName];
        [self loadDirection];
    }
    else if (self.currentStep == BusSelectStepSelectStation) {
        NSDictionary *station = [self.stations objectAtIndex:row];
        self.stationField.text = [station objectForKey:kStationName];
        for (NSString *key in [self.formDict allKeys]) {
            if ([key rangeOfString:@"imgBtn."].location != NSNotFound) {
                [self.formDict removeObjectForKey:key];
            }
        }
        [self.formDict setObject:@(0) forKey:[NSString stringWithFormat:@"rpt$ctl%02d$imgBtn.x", row]];
        [self.formDict setObject:@(0) forKey:[NSString stringWithFormat:@"rpt$ctl%02d$imgBtn.y", row]];
    }
}

#pragma mark - Load webpage and parse
//选择公车路线
- (void)loadBusRoutesNeedRefresh:(BOOL)needRefresh {
    self.defaults = [NSUserDefaults standardUserDefaults];
    NSArray *busRoutes = [self.defaults objectForKey:kBusStorage];
    NSDictionary *formDict = [self.defaults objectForKey:kBusFormPartitialStorage];
    if (busRoutes != nil && !needRefresh) {
        self.currentStep = BusSelectStepSelectBus;
        self.busRoutes = busRoutes;
        [self.formDict removeAllObjects];
        [self.formDict addEntriesFromDictionary:formDict];
        self.busSelectButton.enabled = YES;
        [self.pickerView selectRow:0 inComponent:0 animated:YES];
        return;
    }
    [[AppDelegate shared] showHUDLoadingInView:self.view withMessage:@"公交线路加载中..."];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.serverAddress]];
    __block ASIHTTPRequest *request_b = request;
    __block ViewController *vc = self;
    [request setCompletionBlock:^{
        NSData *responseData = [request_b responseData];
        WXBusParser *parser = [[WXBusParser alloc] initWithData:responseData];
        [parser parse];
        
        self.busRoutes = parser.busRoutes;
        self.stations = parser.stations;
        self.directionRoutes = parser.directionRoutes;
        self.formDict = parser.formDict;
        [vc->_pickerView reloadComponent:0];
        [vc->_pickerView selectRow:0 inComponent:0 animated:YES];
        
        // 保存公交路线和ViewState表单。
        [self.defaults setObject:self.busRoutes forKey:kBusStorage];
        [self.defaults setObject:self.formDict forKey:kBusFormPartitialStorage];
        [self.defaults synchronize];
        
        [[AppDelegate shared] hideHUD];
        self.busSelectButton.enabled = YES;
    }];
    
    [request setFailedBlock:^{
        [[AppDelegate shared] hideHUDWithMessage:@"请求超时，请重试！"];
        self.busRoutes = @[@{kBusName: @"请重试"}];
        self.busSelectButton.enabled = YES;
        [self.pickerView reloadAllComponents];
    }];
    
    [request startAsynchronous];
}

- (void)loadPickerForStationsAtIndex:(NSInteger)index {
    NSDictionary *directionRoute = [self.directionRoutes objectAtIndex:index];
    self.directionField.text = [directionRoute objectForKey:kBusName];
    
    [self.pickerView reloadComponent:0];
    [self.pickerView selectRow:0 inComponent:0 animated:YES];
    
    [self.formDict setObject:[directionRoute objectForKey:kBusID] forKey:@"ddlSegment"];
    
    self.stationField.text = [[self.stations objectAtIndex:0] objectForKey:kStationName];
    [self.formDict setObject:@(0) forKey:@"rpt$ctl00$imgBtn.x"];
    [self.formDict setObject:@(0) forKey:@"rpt$ctl00$imgBtn.y"];
}

//选择方向同时加载站名
- (void)loadDirection {
    [[AppDelegate shared] showHUDLoadingInView:self.view withMessage:@"公交站名加载中..."];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.serverAddress]];
    for (id key in [self.formDict allKeys]) {
        [request setPostValue:[self.formDict objectForKey:key] forKey:key];
    }
    
    __block ASIFormDataRequest *request_b = request;
    __block ViewController *vc = self;
    
    [request setCompletionBlock:^{
        [[AppDelegate shared] hideHUD];
        NSData *responseData = [request_b responseData];
        WXBusParser *parser = [[WXBusParser alloc] initWithData:responseData];
        [parser parse];
        
        self.busRoutes = parser.busRoutes;
        self.stations = parser.stations;
        self.directionRoutes = parser.directionRoutes;
        self.formDict = parser.formDict;
        
        if ([self.directionRoutes count] > 1) {
            self.directionSelectButton.hidden = NO;
            self.currentStep = BusSelectStepSelectDirection;
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择行车方向" completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                [self.formDict setObject:[[self.directionRoutes objectAtIndex:(buttonIndex)] objectForKey:kBusID] forKey:@"ddlSegment"];
                if (buttonIndex == 0) {
                    self.stations = parser.stations;
                    self.currentStep = BusSelectStepSelectStation;
                    [self loadPickerForStationsAtIndex:buttonIndex];
                }
                else {
                    [self loadStationsForIndex:buttonIndex];
                }
            } cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            for (NSDictionary *directionRoute in self.directionRoutes) {
                [sheet addButtonWithTitle:[directionRoute objectForKey:kBusName]];
            }
            [sheet showInView:vc.view];
        }
        else if ([parser.directionRoutes count] == 0) {
            [[[UIAlertView alloc] initWithTitle:@"提示" message:@"该路线暂无状态信息。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }
        else {
            self.directionSelectButton.hidden = YES;
            self.currentStep = BusSelectStepSelectStation;
            
            self.stations = parser.stations;
            [self loadPickerForStationsAtIndex:0];
        }
    }];
    
    [request setFailedBlock:^{
        self.currentStep = BusSelectStepSelectBus;
        [[AppDelegate shared] hideHUDWithMessage:@"请求超时，请重试！"];
    }];
    
    [request startAsynchronous];
}

// 在有方向选择时加载站名
- (void)loadStationsForIndex:(NSInteger)index {
    [[AppDelegate shared] showHUDLoadingInView:self.view withMessage:@"公交站点加载中..."];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.serverAddress]];
    for (id key in [self.formDict allKeys]) {
        [request setPostValue:[self.formDict objectForKey:key] forKey:key];
    }
    
    __block ASIFormDataRequest *request_b = request;
    
    [request setCompletionBlock:^{
        [[AppDelegate shared] hideHUD];
        self.currentStep = BusSelectStepSelectStation;
        NSData *responseData = [request_b responseData];
        WXBusParser *parser = [[WXBusParser alloc] initWithData:responseData];
        [parser parse];
        
        self.busRoutes = parser.busRoutes;
        self.stations = parser.stations;
        self.directionRoutes = parser.directionRoutes;
        self.formDict = parser.formDict;
        
        [self loadPickerForStationsAtIndex:index];
    }];
    
    [request setFailedBlock:^{
        self.currentStep = BusSelectStepSelectBus;
        [[AppDelegate shared] hideHUDWithMessage:@"请求超时，请重试！"];
    }];
    
    [request startAsynchronous];
}

// 查看公交车状态
- (IBAction)showBusStatus:(id)sender {
    if ([[self.stationField.text strip] isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"错误" message:@"请先选择乘车方向和候车站点。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    [[AppDelegate shared] showHUDLoadingInView:self.view withMessage:@"公交位置加载中..."];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.serverAddress]];
    for (id key in [self.formDict allKeys]) {
        [request setPostValue:[self.formDict objectForKey:key] forKey:key];
    }
#if TARGET_IS_DEBUG
    //NSLog(@"%@", self.formDict);
#endif
    // 保存查询公车状态的表单
    [self.defaults setObject:self.formDict forKey:kBusStatusFormStorage];
    
    __block ASIFormDataRequest *request_b = request;
    [request setCompletionBlock:^{
        [[AppDelegate shared] hideHUD];
        NSData *responseData = [request_b responseData];
        WXBusParser *parser = [[WXBusParser alloc] initWithData:responseData];
        [parser parse];
        
        self.busRoutes = parser.busRoutes;
        self.stations = parser.stations;
        self.directionRoutes = parser.directionRoutes;
        self.formDict = parser.formDict;
        
        if ([parser.nextBuses isKindOfClass:NSClassFromString(@"NSString")]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:parser.nextBuses delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        else if (parser.nextBuses == nil || [parser.nextBuses count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"未知错误" message:@"发生未知错误，请联系开发人员处理这个问题。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
        }
        else {
            BusStatusViewController *busStatusVC = [[BusStatusViewController alloc] initWithStyle:UITableViewStyleGrouped];
            busStatusVC.currentStationName = [[self.stations objectAtIndex:[self.pickerView selectedRowInComponent:0]] objectForKey:kStationName];
            busStatusVC.nextBuses = parser.nextBuses;
            busStatusVC.currentBusName = self.busField.text;
            [self.navigationController pushViewController:busStatusVC animated:YES];
        }
    }];
    
    [request setFailedBlock:^{
        [[AppDelegate shared] hideHUDWithMessage:@"请求超时，请重试！"];
    }];
    
    [request startAsynchronous];
}

@end
