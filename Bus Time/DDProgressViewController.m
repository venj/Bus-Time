//
//  DDProgressViewController.m
//  DDProgressApp
//
//  Created by 朱 文杰 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DDProgressViewController.h"
#import "DDProgressView.h"

@interface DDProgressViewController ()
- (void)hideProgressView;
- (void)showProgressView;
@end

@implementation DDProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.progress = 0;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.opaque = NO;
    self.view.alpha = 0.8;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressView.progress = progress;
}

- (void)show {
    [self showProgressView];
    
    if ([self.delegate respondsToSelector:@selector(progressViewDidShow)]) {
        [self.delegate progressViewDidShow];
    }
}

- (void)finished {
    [self hideProgressView];
    
    if ([self.delegate respondsToSelector:@selector(progressViewDidFinished)]) {
        [self.delegate progressViewDidFinished];
    }
}

- (void)cancel {
    [self hideProgressView];
    
    if ([self.delegate respondsToSelector:@selector(progressViewDidCancel)]) {
        [self.delegate progressViewDidCancel];
    }
}

- (void)hideProgressView {
    self.progress = 0;
    [self.view removeFromSuperview];
}

- (void)showProgressView {
    if (self.cancelButton == nil) {
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.frame = CGRectMake(120., 242., 80., 32.);
        [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton setTitleColor:[UIColor colorWithRed:0.06f green:0.52f blue:0.98f alpha:1.00f] forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor colorWithRed:0.11f green:0.38f blue:0.94f alpha:1.0f] forState:UIControlStateHighlighted];
        [self.view addSubview:self.cancelButton];
    }
    
    if (self.progressView == nil) {
        self.progressView = [[DDProgressView alloc] initWithFrame:CGRectMake(20.0f, 202.0f, self.view.frame.size.width-40.0f, 0.0f)];
        [self.progressView setOuterColor:[UIColor lightGrayColor]];
        [self.progressView setInnerColor:[UIColor whiteColor]];
        [self.view addSubview:self.progressView];
    }
    
    [self.delegate.view.window addSubview:self.view];
}

@end
