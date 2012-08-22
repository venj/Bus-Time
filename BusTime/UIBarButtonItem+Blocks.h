//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//


/**
self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" 
                                                                         style:UIBarButtonItemStylePlain 
                                                                       handler:^(id sender) {
                                                                           
                                                                           [[cl_NotificationUpdateManager shared] unregiest:self];
                                                                           [self.navigationController popViewControllerAnimated:YES];
                                                                      }];
 */
@interface UIBarButtonItem (Blocks)

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem handler:(void(^)(id sender))action;

- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style handler:(void(^)(id sender))action;

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style handler:(void(^)(id sender))action;

@end
