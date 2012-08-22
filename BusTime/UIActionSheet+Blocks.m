//
//  EMOFrameworkKit
//
//  Created by 涛 傅 on 11-12-13.
//  Copyright (c) 2011年 com.ftkey. All rights reserved.
//

#import "UIActionSheet+Blocks.h"
#import "NSObject+AssociatedObjects.h"

@implementation UIActionSheet (Blocks)
static char *kActionSheetBlockKey = "kUIActionSheetBlockHandlerKey"; 

- (id)initWithTitle:(NSString *)title completionBlock:(void (^)(NSUInteger buttonIndex, UIActionSheet *actionSheet))block cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    [self associateCopyOfValue:block withKey:kActionSheetBlockKey];
	if (self = [self initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil]) {
        
		if (destructiveButtonTitle) {
			[self addButtonWithTitle:destructiveButtonTitle];
			self.destructiveButtonIndex = [self numberOfButtons] - 1;
		}
        
		id eachObject;
		va_list argumentList;
		if (otherButtonTitles) {
			[self addButtonWithTitle:otherButtonTitles];
			va_start(argumentList, otherButtonTitles);
			while ((eachObject = va_arg(argumentList, id))) {
				[self addButtonWithTitle:eachObject];
			}
			va_end(argumentList);
		}
        
		if (cancelButtonTitle) {
			[self addButtonWithTitle:cancelButtonTitle];
			self.cancelButtonIndex = [self numberOfButtons] - 1;
		}
	}	
	return self;
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	void (^block)(NSUInteger buttonIndex, UIActionSheet *actionSheet) = [self associatedValueForKey:kActionSheetBlockKey];
	block(buttonIndex, self);
    [self removeAssociatedValueForKey:kActionSheetBlockKey];

}
@end