//
//  InfoPageViewController.h
//  Bus Time
//
//  Created by venj on 13-1-4.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoPageViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSURL *linkURL;
@end
