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
#import "MBProgressHUD.h"
#import "cl_BlockHead.h"
#import "TFHpple.h"
#import "HandyFoundation.h"
#import "BusStatusViewController.h"
#import "Common.h"
#import "SettingsViewController.h"

#define TARGET_IS_BETA 0

@interface ViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NSMutableArray *busRoutes;
@property (strong, nonatomic) NSMutableArray *directionRoutes;
@property (strong, nonatomic) NSMutableArray *stations;
@property (strong, nonatomic) NSMutableDictionary *formDict;
@property (strong, nonatomic) MBProgressHUD *hud;
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain handler:^(id sender) {
        [[[UIAlertView alloc] initWithTitle:@"提示" message:@"你真的需要重新载入公交列表吗？" completionBlock:^(NSUInteger buttonIndex) {
            if (buttonIndex != 0) {
                [self loadBusRoutesNeedRefresh:YES];
            }
        } cancelButtonTitle:@"取消" otherButtonTitles:@"确定"] show];
    }];
    
    if (!self.busRoutes) {
        self.busRoutes = [[NSMutableArray alloc] init];
    }
    if (!self.directionRoutes) {
        self.directionRoutes = [[NSMutableArray alloc] init];
    }
    if (!self.formDict) {
        self.formDict = [[NSMutableDictionary alloc] init];
    }
    if (!self.stations) {
        self.stations = [[NSMutableArray alloc] init];
    }
    self.currentStep = BusSelectStepSelectBus;
    [self loadBusRoutesNeedRefresh:NO];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
                self.stationField.text = @"";
                self.directionField.text = @"";
                [self.stations removeAllObjects];
                [self.directionRoutes removeAllObjects];
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
                [self loadStations];
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
        //NSLog(@"%@", [[self.busRoutes objectAtIndex:row] objectForKey:@"BusID"]);
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
        [self.busRoutes removeAllObjects];
        [self.busRoutes addObjectsFromArray:busRoutes];
        [self.formDict removeAllObjects];
        [self.formDict addEntriesFromDictionary:formDict];
        self.busSelectButton.enabled = YES;
        return;
    }
    [self showHUDLoadingWithMessage:@"公交线路加载中..."];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.serverAddress]];
    __block ASIHTTPRequest *request_b = request;
    __block ViewController *vc = self;
    [request setCompletionBlock:^{
        NSData *responseData = [request_b responseData];
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseData];
        NSArray *elements = [doc searchWithXPathQuery:@"//select"];
        [self.busRoutes removeAllObjects];
        for (TFHppleElement *element in [[elements objectAtIndex:0] children]) {
            [self.busRoutes addObject:@{kBusName: [[element firstChild] content], kBusID: [element objectForKey:@"value"]}];
        }
        [vc->_pickerView reloadComponent:0];
        
        NSArray *formElements = [doc searchWithXPathQuery:@"//form/input"];
        for (TFHppleElement *element in formElements) {
            [self.formDict setObject:[element objectForKey:@"value"] forKey:[element objectForKey:@"name"]];
        }
        
        [self.defaults setObject:self.busRoutes forKey:kBusStorage];
        [self.defaults setObject:self.formDict forKey:kBusFormPartitialStorage];
        [self.defaults synchronize];
        [self.hud hide:YES];
        self.busSelectButton.enabled = YES;
    }];
    
    [request setFailedBlock:^{
        [self hideHUDWithMessage:@"请求超时，请重试！"];
        [self.busRoutes removeAllObjects];
        [self.busRoutes addObject:@{kBusName: @"请重试"}];
        self.busSelectButton.enabled = YES;
        [self.pickerView reloadAllComponents];
    }];
    
    [request startAsynchronous];
}

//选择方向
- (void)loadDirection {
    [self showHUDLoadingWithMessage:@"公交站名加载中..."];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.serverAddress]];
    for (id key in [self.formDict allKeys]) {
        [request setPostValue:[self.formDict objectForKey:key] forKey:key];
    }
    
    __block ASIFormDataRequest *request_b = request;
    __block ViewController *vc = self;
    
    [request setCompletionBlock:^{
        [self.hud hide:YES];
        NSData *responseData = [request_b responseData];
        //NSLog(@"%@", [request_b responseString]);
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseData];
        NSArray *elements = [doc searchWithXPathQuery:@"//select"];
        NSArray *subElements = [[elements objectAtIndex:1] children];
        //NSLog(@"%@", [elements objectAtIndex:1]);
        if ([subElements count] > 1) { //有方向选择的
            self.directionSelectButton.hidden = NO;
            self.currentStep = BusSelectStepSelectDirection;
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择行车方向" completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
                [self.formDict setObject:[[self.directionRoutes objectAtIndex:(buttonIndex)] objectForKey:kBusID] forKey:@"ddlSegment"];
                self.directionField.text = [[self.directionRoutes objectAtIndex:(buttonIndex)] objectForKey:kBusName];
                [self loadStations];
                /*if (buttonIndex == 0) {
                    self.currentStep = BusSelectStepSelectStation;
                    [self.formDict setObject:[[subElements objectAtIndex:0] objectForKey:@"value"] forKey:@"ddlSegment"];
                    self.directionField.text = [[[subElements objectAtIndex:0] firstChild] content];
                    [self loadStationsWithHTMLData:responseData];
                }
                else {
                    [self loadStations];
                }*/
            } cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
            
            [self.directionRoutes removeAllObjects];
            
            for (TFHppleElement *element in subElements) {
                [self.directionRoutes addObject:@{kBusName: [[element firstChild] content], kBusID: [element objectForKey:@"value"]}];
                [sheet addButtonWithTitle:[[element firstChild] content]];
            }
            [sheet showInView:vc.view];
        }
        else if ([subElements count] == 0) {
            NSArray *tables = [doc searchWithXPathQuery:@"//table[@class='table_inside']"];
            TFHppleElement *table = [tables objectAtIndex:1];
            if ([[[[table children] objectAtIndex:0] children] count] == 0) {
                [[[UIAlertView alloc] initWithTitle:@"提示" message:@"该路线暂无状态信息。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
            }
            else {
                [self loadBusRoutesNeedRefresh:YES];
            }
        }
        else { //没有方向选择的
            self.directionSelectButton.hidden = YES;
            self.currentStep = BusSelectStepSelectStation;
            [self.formDict setObject:[[subElements objectAtIndex:0] objectForKey:@"value"] forKey:@"ddlSegment"];
            //NSLog(@"%@", [[subElements objectAtIndex:0] objectForKey:@"value"]);
            self.directionField.text = [[[subElements objectAtIndex:0] firstChild] content];
            [self loadStationsWithHTMLData:responseData];
        }
    }];
    
    [request setFailedBlock:^{
        self.currentStep = BusSelectStepSelectBus;
        [self hideHUDWithMessage:@"请求超时，请重试！"];
    }];
    
    [request startAsynchronous];
}

- (void)loadStations {
    [self showHUDLoadingWithMessage:@"公交站点加载中..."];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.serverAddress]];
    for (id key in [self.formDict allKeys]) {
        [request setPostValue:[self.formDict objectForKey:key] forKey:key];
    }
    
    __block ASIFormDataRequest *request_b = request;
    
    [request setCompletionBlock:^{
        [self.hud hide:YES];
        self.currentStep = BusSelectStepSelectStation;
        NSData *responseData = [request_b responseData];
        
        [self loadStationsWithHTMLData:responseData];
    }];
    
    [request startAsynchronous];
}

- (void)loadStationsWithHTMLData:(NSData *)htmlData {
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:htmlData];
    NSArray *elements = [doc searchWithXPathQuery:@"//table[@class='table_inside']/tr/td/table"];

    [self.stations removeAllObjects];
    for (NSInteger i = 2; i < [elements count]; i++) {
        NSMutableDictionary *station = [[NSMutableDictionary alloc] init];
        NSArray *children = [[[[[elements objectAtIndex:i] children] objectAtIndex:0] firstChild] children]; // <input> etc.
        for (TFHppleElement *e in children) {
            if ([[e tagName] isEqualToString:@"input"] && [[e objectForKey:@"type"] isEqualToString:@"hidden"] && [e objectForKey:@"value"]) {
                [station setObject:[e objectForKey:@"value"] forKey:[e objectForKey:@"name"]];
            }
        }
        
        for (TFHppleElement *e in [[[[elements objectAtIndex:i] children] objectAtIndex:1] children]) {
            if ([[e tagName] isEqualToString:@"td"]) {
                for (TFHppleElement *c in [e children]) {
                    if ([[c tagName] isEqualToString:@"span"]) {
                        [station setObject:[[c firstChild] content] forKey:kStationName];
                        //NSLog(@"%@", [[c firstChild] content]);
                    }
                }
            }
        }
        
        [self.stations addObject:station];
    }
    
    [self.pickerView reloadComponent:0];
    [self.pickerView selectRow:0 inComponent:0 animated:YES];
    self.stationField.text = [[self.stations objectAtIndex:0] objectForKey:kStationName];
    
    [self.formDict removeAllObjects];
    NSArray *formElements = [doc searchWithXPathQuery:@"//input"];
    for (TFHppleElement *element in formElements) {
        if ([element objectForKey:@"value"] == nil) {
            continue;
        }
        else {
            [self.formDict setObject:[element objectForKey:@"value"] forKey:[element objectForKey:@"name"]];
        }
    }
    
    NSMutableDictionary *formDict = [[self.defaults objectForKey:kBusFormPartitialStorage] mutableCopy];
    [formDict setObject:[self.formDict objectForKey:@"__VIEWSTATE"] forKey:@"__VIEWSTATE"];
    [self.defaults setObject:formDict forKey:kBusFormPartitialStorage];
    [self.defaults synchronize];
    
    [self.formDict setObject:@(0) forKey:@"rpt$ctl00$imgBtn.x"];
    [self.formDict setObject:@(0) forKey:@"rpt$ctl00$imgBtn.y"];
    //NSLog(@"%@", self.formDict);
}

- (IBAction)showBusStatus:(id)sender {
    if ([[self.stationField.text strip] isEqualToString:@""]) {
        [[[UIAlertView alloc] initWithTitle:@"错误" message:@"请先选择乘车方向和候车站点。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        return;
    }
    
    [self showHUDLoadingWithMessage:@"公交位置加载中..."];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[[NSURL alloc] initWithString:self.serverAddress]];
    for (id key in [self.formDict allKeys]) {
        [request setPostValue:[self.formDict objectForKey:key] forKey:key];
    }
    //NSLog(@"%@", self.formDict);
    //return;
    __block ASIFormDataRequest *request_b = request;
    //__block ViewController *vc = self;
    
    [request setCompletionBlock:^{
        [self.hud hide:YES];
        NSData *responseData = [request_b responseData];
        //NSLog(@"%@", [request_b responseString]);
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseData];
        NSArray *elements = [doc searchWithXPathQuery:@"//table[@class='table_inside']/tr/td/span/font"];
        NSString *message = [[[elements objectAtIndex:0] firstChild] content];
        if ([message length] > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
            [alert show];
            return;
        }
        else {
            elements = [doc searchWithXPathQuery:@"//table[@class='table_inside']//div/table/tr"];
            NSMutableArray *nextBuses = [[NSMutableArray alloc] initWithCapacity:1];
            for (NSInteger i = 1; i < [elements count]; i++) {
                TFHppleElement *element = [elements objectAtIndex:i];
                NSArray *children = [element children];
                NSMutableArray *bus = [[NSMutableArray alloc] initWithCapacity:3];
                for (TFHppleElement *child in children) {
                    NSString *text = [[[child firstChild] content] strip];
                    if ([text length] > 0) {
                        [bus addObject:text];
                    }
                }
                [nextBuses addObject:bus];
            }
            
            BusStatusViewController *busStatusVC = [[BusStatusViewController alloc] initWithStyle:UITableViewStyleGrouped];
            busStatusVC.currentStationName = [[self.stations objectAtIndex:[self.pickerView selectedRowInComponent:0]] objectForKey:kStationName];
            busStatusVC.nextBuses = nextBuses;
            [self.navigationController pushViewController:busStatusVC animated:YES];
        }
    }];
    
    [request setFailedBlock:^{
        [self hideHUDWithMessage:@"请求超时，请重试！"];
    }];
    
    [request startAsynchronous];
}

#pragma mark - MBProgressHUD Helper and Delegate

- (void)showHUDLoadingWithMessage:(NSString *)message {
    if (self.hud) {
        [self.hud hide:YES];
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:self.hud];
	
    self.hud.delegate = self;
    self.hud.labelText = message;
	[self.hud show:YES];
}

- (void)showHUDWithMessage:(NSString *)message isWarning:(BOOL)warningOrDone {
    if (self.hud) {
        [self.hud hide:YES];
        [self.hud removeFromSuperview];
        self.hud = nil;
    }
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.mode = MBProgressHUDModeCustomView;
    if (warningOrDone) {
        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"32x-Exclamationmark"]];
    }
    else {
        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark"]];
    }
	[self.view addSubview:self.hud];
	
    self.hud.delegate = self;
    self.hud.labelText = message;
	[self.hud show:YES];
    [self.hud hide:YES afterDelay:2];
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    if (hud) {
        [hud removeFromSuperview];
        hud = nil;
    }
}

- (void)hideHUDWithMessage:(NSString *)message {
    if (self.hud) {
        self.hud.labelText = message;
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"32x-Exclamationmark"]];
        [self.hud hide:YES afterDelay:2];
    }
}

@end
