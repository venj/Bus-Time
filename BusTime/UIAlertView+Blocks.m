//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

#import "UIAlertView+Blocks.h"
#import "NSObject+AssociatedObjects.h"


@implementation UIAlertView (Blocks)
static char *kAlertViewHandlerKey = "kUIAlertViewHandlerKey";


- (id)initWithTitle:(NSString *)title message:(NSString *)message completionBlock:(void (^)(NSUInteger buttonIndex))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    [self associateCopyOfValue:block withKey:kAlertViewHandlerKey];
    
    return [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles, nil];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^block)(NSUInteger buttonIndex) = [self associatedValueForKey:kAlertViewHandlerKey];
    block(buttonIndex);
    [self removeAssociatedValueForKey:kAlertViewHandlerKey];

}

@end