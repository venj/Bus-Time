//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

/**

[[[UIAlertView alloc] initWithTitle:@"Some Title" message:@"Are you sure you want to do this?" completionBlock:^(NSUInteger buttonIndex) {
    switch (buttonIndex) {
        case 0:
            NSLog(@"Not doing it");
            break;
        case 1:
            NSLog(@"I'm doing it!");
            break;
            break;
    }
} cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] show];
*/
@interface UIAlertView (Blocks)<UIAlertViewDelegate>;

- (id)initWithTitle:(NSString *)title message:(NSString *)message completionBlock:(void (^)(NSUInteger buttonIndex))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
