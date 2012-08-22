//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

/**
 [[[UIActionSheet alloc] initWithTitle:@"Some Title" 
    completionBlock:^(NSUInteger buttonIndex, UIActionSheet *actionSheet) {
        switch (buttonIndex) {
        case 0:
            NSLog(@"Not doing it");
            break;
        case 1:
            NSLog(@"I'm doing it!");
            break;
        }
    } 
    cancelButtonTitle:@"Cancel" 
    destructiveButtonTitle:@"OK" 
    otherButtonTitles:nil] 
 show]
 */
@interface UIActionSheet (Blocks) <UIActionSheetDelegate>

- (id)initWithTitle:(NSString *)title completionBlock:(void (^)(NSUInteger buttonIndex, UIActionSheet *actionSheet))block cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
