//
//  main.m
//  BusTime
//
//  Created by 朱 文杰 on 12-8-20.
//  Copyright (c) 2012年 朱 文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-Hans", nil] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
