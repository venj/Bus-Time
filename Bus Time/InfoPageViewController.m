//
//  InfoPageViewController.m
//  Bus Time
//
//  Created by venj on 13-1-4.
//  Copyright (c) 2013年 venj. All rights reserved.
//

#import "InfoPageViewController.h"

@interface InfoPageViewController ()<UIWebViewDelegate>

@end

@implementation InfoPageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.webView.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:115./255. green:123./255. blue:143./255. alpha:1];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.linkURL];
    [self.webView loadRequest:request];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] bk_initWithBarButtonSystemItem:UIBarButtonSystemItemDone handler:^(id sender) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    return YES;
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([[webView.request.URL absoluteString] rangeOfString:@"http://"].location != NSNotFound) {
        NSString *js = @"var arr = document.getElementsByTagName('div');"
                        "for(var i = 0; i < arr.length; i++){ "
                        "    var oldcss = arr[i].style.cssText;"
                        "    arr[i].style.cssText += 'color:black;padding-top:10px;';"
                        "}"
                        "var hr = document.getElementsByTagName('hr');"
                        "hr[0].hidden=true;"
                        "var spans = document.getElementsByTagName('span');"
                        "spans[spans.length - 1].style.cssText += 'padding:0 10 5 0;font-size:1em;color:gray;'; ";
        [webView stringByEvaluatingJavaScriptFromString:js];
    }
}

@end
