//
//  DDProgressViewController.h
//  DDProgressApp
//
//  Created by 朱 文杰 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDProgressView;

@protocol DDProgressViewDelegate <NSObject>
@optional
- (void)progressViewDidShow;
- (void)progressViewDidFinished;
- (void)progressViewDidCancel;
@end

@interface DDProgressViewController : UIViewController

@property (nonatomic, strong) DDProgressView *progressView;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, weak) UIViewController<DDProgressViewDelegate> *delegate;
@property (nonatomic, strong) UIButton *cancelButton;

- (void)show; //显示
- (void)finished; //完成
- (void)cancel; //取消

@end
