//
//  VCNavigationBar.m
//  Bus Time
//
//  Created by 朱 文杰 on 13-4-17.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import "VCNavigationBar.h"

@implementation VCNavigationBar
- (void)layoutSubviews {
    [super layoutSubviews];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
}

- (void)doubleTapped:(UITapGestureRecognizer *)tap {
    // Assume it is used by UINavigationController.
    if ([self.delegate respondsToSelector:@selector(popToRootViewControllerAnimated:)]) {
        [self.delegate popToRootViewControllerAnimated:YES];
    }
}

@end
