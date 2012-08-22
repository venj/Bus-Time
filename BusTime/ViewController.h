//
//  ViewController.h
//  BusTime
//
//  Created by 朱 文杰 on 12-8-20.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum BusSelectStep : NSInteger {
    BusSelectStepSelectBus = 0,
    BusSelectStepSelectDirection,
    BusSelectStepSelectStation
} BusSelectStep;

@interface ViewController : UIViewController

@end
